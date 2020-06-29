# frozen_string_literal: true

# Slack commands controller.
class SlashCommandsController < ApplicationController
  include SlashCommandsHelper
  skip_before_action :verify_authenticity_token

  def channel_connect
    signing_secret = RedmineSlack.settings[:redmine_slack_signing_secret]
    data = []
    if valid_request?(request.headers, request.raw_post, signing_secret)
      channel_name = params[:channel_name]
      project_slug = params[:text]
      data = []
      project = Project.where(['identifier = ?', project_slug]).first
      unless project
        # Try by id.
        project = Project.where(['id = ?', project_slug]).first
        unless project
          data = "Project #{project_slug} not found"
        end
      end
      if project
        slack_setting = RedmineSlackSetting.find_or_create(project.id)
        if slack_setting.redmine_slack_channel
          previous_channel_name = slack_setting.redmine_slack_channel
          if previous_channel_name != channel_name
            slack_setting.redmine_slack_channel = channel_name
            slack_setting.save!
            data = "Project channel updated. It was previously set to #{previous_channel_name}."
          else
            data = "Nothing to do. Project was already set to channel #{channel_name}."
          end
        else
          slack_setting.redmine_slack_channel = channel_name
          slack_setting.save!
          data = "Project channel set to #{channel_name}."
        end
      end
    else
      data = 'Invalid Request'
    end
    respond_to do |format|
      format.html {render json: data, status: :ok, layout: nil}
    end
  end
end
