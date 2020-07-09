# frozen_string_literal: true

# Slack settings model class.
class RedmineSlackSetting < ActiveRecord::Base
  belongs_to :project

  def self.find_or_create(p_id)
    setting = RedmineSlackSetting.find_by(project_id: p_id)
    unless setting
      setting = RedmineSlackSetting.new
      setting.project_id = p_id
    end

    setting
  end
end
