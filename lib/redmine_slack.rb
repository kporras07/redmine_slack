# frozen_string_literal: true

Rails.configuration.to_prepare do
  # Redmine Slack module.
  module RedmineSlack
    def self.settings
      if Setting[:plugin_redmine_slack].class == Hash
        if Rails.version >= '5.2'
          # convert Rails 4 data
          new_settings = ActiveSupport::HashWithIndifferentAccess.new(Setting[:plugin_redmine_slack])
          Setting.plugin_redmine_slack = new_settings
          new_settings
        else
          ActionController::Parameters.new(Setting[:plugin_redmine_slack])
        end
      else
        # Rails 5 uses ActiveSupport::HashWithIndifferentAccess
        Setting[:plugin_redmine_slack]
      end
    end

    def self.setting?(value)
      return true if settings[value].to_i == 1

      false
    end
  end

  # Patches
  Issue.include RedmineSlack::Patches::IssuePatch
  WikiContent.include RedmineSlack::Patches::WikiContentPatch
  ProjectsController.send :helper, RedmineSlackProjectsHelper

  # Global helpers
  ActionView::Base.include RedmineSlack::Helpers

  # Hooks
  require_dependency 'redmine_slack/hooks'
end
