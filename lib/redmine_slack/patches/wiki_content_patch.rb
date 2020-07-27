# frozen_string_literal: true

# Redmine Slack module to add patches.
module RedmineSlack
  # Patches module.
  module Patches
    # Patches for wiki content.
    module WikiContentPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_redmine_slack_create
          after_commit :send_redmine_slack_update, :on => :update
        end
      end

      # Instance methods.
      module InstanceMethods
        def send_redmine_slack_create
          return unless Slack.setting_for_project(project, :post_wiki)

          set_language_if_valid Setting.default_language

          channels = Slack.channels_for_project project

          return if channels.blank?

          attachment = {}
          attachment[:fields] = []
          attachment[:fields] << {
            title: 'Content',
            value: Slack.trim(text, project),
            short: false
          }

          attachment[:color] = Slack.textfield_for_project(project, :color_create_notifications)

          notification = RedmineSlackNotification.find_or_create_within_timeframe(
            'wiki-content',
            id,
            Slack.textfield_for_project(project, :update_notification_threshold)
          )

          Slack.speak(
            l(
              :label_redmine_slack_wiki_created,
              project_url: "<#{Slack.object_url project}|#{ERB::Util.html_escape(project)}>",
              url: "<#{Rails.application.routes.url_for(
                :controller => 'wiki',
                :action => 'show',
                :project_id => project,
                :id => page.title,
                :host => Setting.host_name
              )}|#{page.title}>",
              user: User.current
            ),
            channels,
            {project: project, attachment: attachment},
            notification
          )
        end

        def send_redmine_slack_update
          return unless Slack.setting_for_project(project, :post_wiki_updates)

          set_language_if_valid Setting.default_language

          channels = Slack.channels_for_project project

          return if channels.blank?

          attachment = nil
          if comments.present?
            attachment = {}
            attachment[:text] = Slack.markup_format(comments.to_s)
          end

          version_to = version

          content_to = versions.find_by(version: version_to)
          content_from = content_to.try(:previous)
          if content_to && content_from
            diff = Diffy.new(content_from.data, content_to.data, :context => 1)
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
            attachment = {} if attachment.nil?
            attachment[:fields] = []
            attachment[:fields] << {
              title: 'Content Differences',
              value: diff_elements.to_a.join("\r\n"),
              short: false
            }
          end

          send_message = true
          if Slack.setting_for_project(project, :supress_empty_messages)
            send_message = false unless attachment.any? && (attachment.key?(:text) || attachment.key?(:fields))
          end

          return unless send_message

          attachment[:color] = Slack.textfield_for_project(project, :color_update_notifications)

          notification = RedmineSlackNotification.find_or_create_within_timeframe(
            'wiki-content',
            id,
            Slack.textfield_for_project(project, :update_notification_threshold)
          )
          if !notification.slack_message_id.nil?
            Slack.update_message(
              l(
                :label_redmine_slack_wiki_updated,
                project_url: "<#{Slack.object_url project}|#{ERB::Util.html_escape(project)}>",
                url: "<#{Rails.application.routes.url_for(
                  :controller => 'wiki',
                  :action => 'show',
                  :project_id => project,
                  :id => page.title,
                  :host => Setting.host_name
                )}|#{page.title}>",
                user: User.current
              ),
              notification.slack_channel_id,
              {project: project, attachment: attachment},
              notification
            )
          else
            Slack.speak(
              l(
                :label_redmine_slack_wiki_updated,
                project_url: "<#{Slack.object_url project}|#{ERB::Util.html_escape(project)}>",
                url: "<#{Rails.application.routes.url_for(
                  :controller => 'wiki',
                  :action => 'show',
                  :project_id => project,
                  :id => page.title,
                  :host => Setting.host_name
                )}|#{page.title}>",
                user: User.current
              ),
              channels,
              {project: project, attachment: attachment},
              notification
            )
          end
        end
      end
    end
  end
end
