class CreateRedmineSlackSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_slack_settings do |t|
      t.references :project, null: false, index: true
      t.string :slack_url
      t.string :messenger_channel
      t.integer :messenger_verify_ssl, default: 0, null: false
      t.integer :auto_mentions, default: 0, null: false
      t.string :default_mentions, default: 0, null: false
      t.integer :post_updates, default: 0, null: false
      t.integer :new_include_description, default: 0, null: false
      t.integer :updated_include_description, default: 0, null: false
      t.integer :post_private_issues, default: 0, null: false
      t.integer :post_private_notes, default: 0, null: false
      t.integer :post_wiki, default: 0, null: false
      t.integer :post_wiki_updates, default: 0, null: false
      t.integer :text_trim_size, default: nil, null: false
      t.integer :supress_empty_messages, default: 0, null: false
    end
  end
end
