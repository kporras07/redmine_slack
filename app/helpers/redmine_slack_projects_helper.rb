# frozen_string_literal: true

# Project helpers module.
module RedmineSlackProjectsHelper
  def project_settings_tabs
    tabs = super

    if User.current.allowed_to?(:manage_redmine_slack, @project)
      tabs << {name: 'redmine_slack',
               action: :show,
               partial: 'redmine_slack_settings/show',
               label: :label_redmine_slack}
    end

    tabs
  end
end
