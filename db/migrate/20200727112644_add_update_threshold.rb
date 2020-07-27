# Add update threshold.
class AddUpdateThreshold < ActiveRecord::Migration[5.2]
  def change
    add_column :redmine_slack_settings, :update_notification_threshold, :integer, default: nil
  end
end
