module RedmineSlack
  module Patches
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_redmine_slack_create
          after_commit :send_redmine_slack_update, :on => :update
        end
      end

      module InstanceMethods
        def send_redmine_slack_create
          channels = RedmineSlack.channels_for_project project
          url = RedmineSlack.url_for_project project

          return unless channels.present? && url
          return if is_private? && !RedmineSlack.setting_for_project(project, :post_private_issues)

          set_language_if_valid Setting.default_language

          attachment = {}
          if description.present? && RedmineSlack.setting_for_project(project, :new_include_description)
            attachment[:text] = RedmineSlack.markup_format(RedmineSlack.trim(description, project))
          end
          attachment[:fields] = [{ title: I18n.t(:field_status),
                                   value: ERB::Util.html_escape(status.to_s),
                                   short: true },
                                 { title: I18n.t(:field_priority),
                                   value: ERB::Util.html_escape(priority.to_s),
                                   short: true }]
          if assigned_to.present?
            attachment[:fields] << { title: I18n.t(:field_assigned_to),
                                     value: ERB::Util.html_escape(assigned_to.to_s),
                                     short: true }
          end

          if RedmineSlack.setting?(:display_watchers) && watcher_users.count.positive?
            attachment[:fields] << {
              title: I18n.t(:field_watcher),
              value: ERB::Util.html_escape(watcher_users.join(', ')),
              short: true
            }
          end

          if attachment.any? && attachment.key?(:text)
            RedmineSlack.speak(l(:label_redmine_slack_issue_created,
                              project_url: "<#{RedmineSlack.object_url project}|#{ERB::Util.html_escape(project)}>",
                              url: send_redmine_slack_mention_url(project, description),
                              user: author),
                            channels, url, attachment: attachment, project: project)
          end
        end

        def send_redmine_slack_update
          return if current_journal.nil?

          channels = RedmineSlack.channels_for_project project
          url = RedmineSlack.url_for_project project

          return unless channels.present? && url && RedmineSlack.setting_for_project(project, :post_updates)
          return if is_private? && !RedmineSlack.setting_for_project(project, :post_private_issues)
          return if current_journal.private_notes? && !RedmineSlack.setting_for_project(project, :post_private_notes)

          set_language_if_valid Setting.default_language

          attachment = {}
          text_diff = {}

          if current_journal.notes.present? && RedmineSlack.setting_for_project(project, :updated_include_description)
            attachment[:text] = RedmineSlack.markup_format(RedmineSlack.trim(current_journal.notes, project))
          end

          current_journal.details.each do |detail|
            if detail && detail.prop_key == "description" && detail.value.present? && detail.old_value.present? && RedmineSlack.setting_for_project(project, :updated_include_description)
              diff = Diffy.new(detail.old_value, detail.value, :context => 1)
              diff_elements = []
              diff.each_with_index do |item, index|
                item_stripped = item.strip.gsub("\r", "").gsub("\r\n", "")
                if item_stripped.length
                  if item[0] == '-'
                    if item_stripped[1..-1].length > 1
                      diff_elements << "~#{item_stripped[1..-1]}~"
                    end
                  elsif item[0] == '+'
                    if item_stripped[1..-1].length > 1
                      diff_elements << "_#{item_stripped[1..-1]}_"
                    end
                  else
                    diff_elements << item_stripped unless item_stripped.include? "No newline at end of file"
                  end
                end
              end
              text_diff = {
                title: 'Description Differences',
                value: RedmineSlack.trim(diff_elements.to_a.join("\r\n"), project),
                short: false
              }
              # Finally, delete description from details to avoid including it as a field.
              current_journal.details.delete(detail)
            end
          end

          fields = current_journal.details.map { |d| RedmineSlack.detail_to_field d, project }
          if status_id != status_id_was
            fields << { title: I18n.t(:field_status),
                        value: ERB::Util.html_escape(status.to_s),
                        short: true }
          end
          if priority_id != priority_id_was
            fields << { title: I18n.t(:field_priority),
                        value: ERB::Util.html_escape(priority.to_s),
                        short: true }
          end
          if assigned_to.present?
            fields << { title: I18n.t(:field_assigned_to),
                        value: ERB::Util.html_escape(assigned_to.to_s),
                        short: true }
          end

          if text_diff.any?
            fields << text_diff
          end

          attachment[:fields] = fields if fields.any?

          send_message = true
          if (RedmineSlack.setting_for_project(project, :supress_empty_messages))
            send_message = false unless ((attachment.any? && (attachment.key?(:text))) || !text_diff.empty?)
          end

          if send_message
            RedmineSlack.speak(l(:label_redmine_slack_issue_updated,
                              project_url: "<#{RedmineSlack.object_url project}|#{ERB::Util.html_escape(project)}>",
                              url: send_redmine_slack_mention_url(project, current_journal.notes),
                              user: current_journal.user),
                            channels, url, attachment: attachment, project: project)
          end
        end

        private

        def send_redmine_slack_mention_url(project, text)
          mention_to = ''
          if RedmineSlack.setting_for_project(project, :auto_mentions) ||
             RedmineSlack.textfield_for_project(project, :default_mentions).present?
            mention_to = RedmineSlack.mentions(project, text)
          end
          "<#{RedmineSlack.object_url(self)}|#{self}>#{mention_to}"
        end
      end
    end
  end
end
