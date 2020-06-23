# frozen_string_literal: true

# Redmine Slack module to add patches.
module RedmineSlack
  # Patches module.
  module Patches
    # Issue Patches.
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_redmine_slack_create
          after_commit :send_redmine_slack_update, :on => :update
        end
      end

      # Instance Methods.
      module InstanceMethods
        def send_redmine_slack_create
          channels = Slack.channels_for_project project

          return if channels.blank?
          return if is_private? && !Slack.setting_for_project(project, :post_private_issues)

          set_language_if_valid Setting.default_language

          attachment = {}
          if description.present? && Slack.setting_for_project(project, :new_include_description)
            attachment[:text] = Slack.markup_format(Slack.trim(description, project))
          end
          attachment[:fields] = [{title: I18n.t(:field_status),
                                  value: ERB::Util.html_escape(status.to_s),
                                  short: true},
                                 {title: I18n.t(:field_priority),
                                  value: ERB::Util.html_escape(priority.to_s),
                                  short: true}]
          if assigned_to.present?
            attachment[:fields] << {title: I18n.t(:field_assigned_to),
                                    value: ERB::Util.html_escape(assigned_to.to_s),
                                    short: true}
          end

          return unless attachment.any? && attachment.key?(:text)

          Slack.speak(l(:label_redmine_slack_issue_created,
                        project_url: "<#{Slack.object_url project}|#{ERB::Util.html_escape(project)}>",
                        url: send_redmine_slack_mention_url(project, description),
                        user: author),
                      channels, attachment: attachment, project: project)
        end

        def send_redmine_slack_update
          return if current_journal.nil?

          channels = Slack.channels_for_project project

          return unless channels.present? && Slack.setting_for_project(project, :post_updates)
          return if is_private? && !Slack.setting_for_project(project, :post_private_issues)
          return if current_journal.private_notes? && !Slack.setting_for_project(project, :post_private_notes)

          set_language_if_valid Setting.default_language

          attachment = {}
          text_diff = {}

          if current_journal.notes.present? && Slack.setting_for_project(project, :updated_include_description)
            attachment[:text] = Slack.markup_format(Slack.trim(current_journal.notes, project))
          end

          current_journal.details.each do |detail|
            unless detail &&
                   detail.prop_key == 'description' &&
                   detail.value.present? &&
                   detail.old_value.present? &&
                   Slack.setting_for_project(project, :updated_include_description)
              next
            end

            diff = Diffy.new(detail.old_value, detail.value, :context => 1)
            diff_elements = []
            diff.each_with_index do |item, _index|
              item_stripped = item.strip.delete("\r").gsub("\r\n", '')
              if item_stripped.length
                if item[0] == '-'
                  diff_elements << "~#{item_stripped[1..-1]}~" if item_stripped[1..-1].length > 1
                elsif item[0] == '+'
                  diff_elements << "_#{item_stripped[1..-1]}_" if item_stripped[1..-1].length > 1
                else
                  diff_elements << item_stripped unless item_stripped.include? 'No newline at end of file'
                end
              end
            end
            text_diff = {
              title: 'Description Differences',
              value: Slack.trim(diff_elements.to_a.join("\r\n"), project),
              short: false
            }
            # Finally, delete description from details to avoid including it as a field.
            current_journal.details.delete(detail)
          end

          fields = current_journal.details.map {|d| Slack.detail_to_field d, project}
          if status_id != status_id_was
            fields << {title: I18n.t(:field_status),
                       value: ERB::Util.html_escape(status.to_s),
                       short: true}
          end
          if priority_id != priority_id_was
            fields << {title: I18n.t(:field_priority),
                       value: ERB::Util.html_escape(priority.to_s),
                       short: true}
          end
          if assigned_to.present?
            fields << {title: I18n.t(:field_assigned_to),
                       value: ERB::Util.html_escape(assigned_to.to_s),
                       short: true}
          end

          fields << text_diff if text_diff.any?

          attachment[:fields] = fields if fields.any?

          send_message = true
          if Slack.setting_for_project(project, :supress_empty_messages)
            send_message = false unless (attachment.any? && attachment.key?(:text)) || !text_diff.empty?
          end

          return unless send_message

          Slack.speak(l(:label_redmine_slack_issue_updated,
                        project_url: "<#{Slack.object_url project}|#{ERB::Util.html_escape(project)}>",
                        url: send_redmine_slack_mention_url(project, current_journal.notes),
                        user: current_journal.user),
                      channels, attachment: attachment, project: project)
        end

        private

        def send_redmine_slack_mention_url(project, text)
          mention_to = ''
          if Slack.setting_for_project(project, :auto_mentions) ||
             Slack.textfield_for_project(project, :default_mentions).present?
            mention_to = Slack.mentions(project, text)
          end
          "<#{Slack.object_url(self)}|#{self}>#{mention_to}"
        end
      end
    end
  end
end
