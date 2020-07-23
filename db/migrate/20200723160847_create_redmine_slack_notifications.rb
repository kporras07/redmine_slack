class CreateRedmineSlackNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_slack_notifications do |t|
      t.integer :timestamp
      t.string :entity
      t.integer :entity_id
      t.string :slack_channel_id
      t.string :slack_message_id
    end
  end
end
