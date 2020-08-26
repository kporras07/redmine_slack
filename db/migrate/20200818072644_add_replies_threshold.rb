# Add replies threshold.
class AddRepliesThreshold < ActiveRecord::Migration[5.2]
  def change
    add_column :redmine_slack_settings, :replies_threshold, :integer, default: nil
  end
end
