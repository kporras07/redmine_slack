# Add color settings.
class AddColorSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :redmine_slack_settings, :color_create_notifications, :string, default: nil
    add_column :redmine_slack_settings, :color_update_notifications, :string, default: nil
  end
end
