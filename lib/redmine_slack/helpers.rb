# frozen_string_literal: true

# Redmine slack module.
module RedmineSlack
  # Helpers module.
  module Helpers
    def project_redmine_slack_options(active)
      options_for_select({l(:label_redmine_slack_settings_default) => '0',
                          l(:label_redmine_slack_settings_disabled) => '1',
                          l(:label_redmine_slack_settings_enabled) => '2'}, active)
    end

    def project_setting_redmine_slack_default_value(value)
      if Slack.default_project_setting(@project, value)
        l(:label_redmine_slack_settings_enabled)
      else
        l(:label_redmine_slack_settings_disabled)
      end
    end
  end
end
