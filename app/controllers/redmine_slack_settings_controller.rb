# frozen_string_literal: true

# Redmine Slack Settings Controller.
class RedmineSlackSettingsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize

  def update
    setting = RedmineSlackSetting.find_or_create(@project.id)
    if setting.update(allowed_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path(@project, tab: 'redmine_slack')
    else
      flash[:error] = setting.errors.full_messages.flatten.join("\n")
      respond_to do |format|
        format.html {redirect_back_or_default(settings_project_path(@project, tab: 'redmine_slack'))}
        format.api  {render_validation_errors(setting)}
      end
    end
  end

  private

  def allowed_params
    params.require(:setting).permit :redmine_slack_token,
                                    :redmine_slack_signing_secret,
                                    :redmine_slack_channel,
                                    :redmine_slack_verify_ssl,
                                    :auto_mentions,
                                    :default_mentions,
                                    :post_updates,
                                    :new_include_description,
                                    :updated_include_description,
                                    :text_trim_size,
                                    :supress_empty_messages,
                                    :post_private_issues,
                                    :post_private_notes,
                                    :post_wiki,
                                    :post_wiki_updates,
                                    :color_create_notifications,
                                    :color_update_notifications,
                                    :replies_threshold,
                                    :color_close_notifications,
                                    :update_notification_threshold
  end
end
