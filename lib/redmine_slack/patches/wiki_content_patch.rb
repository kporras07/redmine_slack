module RedmineSlack
  module Patches
    module WikiContentPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_redmine_slack_create
          after_commit :send_redmine_slack_update, :on => :update
        end
      end

      module InstanceMethods
        def send_redmine_slack_create
          return unless RedmineSlack.setting_for_project(project, :post_wiki)

          set_language_if_valid Setting.default_language

          channels = RedmineSlack.channels_for_project project

          return unless channels.present?

          attachment = {}
          attachment[:fields] = []
          attachment[:fields] << {
            title: 'Content',
            value: RedmineSlack.trim(text, project),
            short: false
          }

          RedmineSlack.speak(l(:label_redmine_slack_wiki_created,
                            project_url: "<#{RedmineSlack.object_url project}|#{ERB::Util.html_escape(project)}>",
                            url: "<#{Rails.application.routes.url_for(
                              :controller => 'wiki',
                              :action => 'show',
                              :project_id => project,
                              :id => page.title,
                              :host => Setting.host_name
                            )}|#{page.title}>",
                            user: User.current),
                          channels, project: project, attachment: attachment)
        end

        def send_redmine_slack_update
          return unless RedmineSlack.setting_for_project(project, :post_wiki_updates)

          set_language_if_valid Setting.default_language

          channels = RedmineSlack.channels_for_project project

          return unless channels.present?

          attachment = nil
          if comments.present?
            attachment = {}
            attachment[:text] = RedmineSlack.markup_format(comments.to_s)
          end

          version_to = version

          content_to = versions.find_by_version(version_to)
          content_from = content_to.try(:previous)
          if content_to && content_from
            diff = Diffy.new(content_from.data, content_to.data, :context => 1)
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
            if attachment.nil?
              attachment = {}
            end
            attachment[:fields] = []
            attachment[:fields] << {
              title: 'Content Differences',
              value: diff_elements.to_a.join("\r\n"),
              short: false
            }
          end

          send_message = true
          if (RedmineSlack.setting_for_project(project, :supress_empty_messages))
            send_message = false unless (attachment.any? && (attachment.key?(:text) || attachment.key?(:fields)))
          end

          if send_message
            RedmineSlack.speak(l(:label_redmine_slack_wiki_updated,
                              project_url: "<#{RedmineSlack.object_url project}|#{ERB::Util.html_escape(project)}>",
                              url: "<#{Rails.application.routes.url_for(
                                :controller => 'wiki',
                                :action => 'show',
                                :project_id => project,
                                :id => page.title,
                                :host => Setting.host_name
                              )}|#{page.title}>",
                              user: User.current),
                            channels, project: project, attachment: attachment)
          end
        end
      end
    end
  end
end
