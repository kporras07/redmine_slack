# Initial migration.
class MigrateRedmineMessengerSettings < ActiveRecord::Migration[5.2]
  def change
    return unless Redmine::Plugin.installed?('redmine_messenger')

    MessengerSetting.where('messenger_url IS NOT NULL').each do |setting|
      next if RedmineSlackSetting.where('project_id = :p_id', {p_id: setting.project_id}).exists?

      new_setting = RedmineSlackSetting.find_or_create(setting.project_id)
      new_setting.redmine_slack_channel = setting.messenger_channel
      new_setting.redmine_slack_verify_ssl = setting.messenger_verify_ssl
      new_setting.auto_mentions = setting.auto_mentions
      new_setting.default_mentions = setting.default_mentions
      new_setting.post_updates = setting.post_updates
      new_setting.new_include_description = setting.new_include_description
      new_setting.updated_include_description = setting.updated_include_description
      new_setting.post_private_issues = setting.post_private_issues
      new_setting.post_private_notes = setting.post_private_notes
      new_setting.post_wiki = setting.post_wiki
      new_setting.post_wiki_updates = setting.post_wiki_updates

      if ActiveRecord::Base.connection.column_exists?(:messenger_settings, :text_trim_size)
        new_setting.text_trim_size = setting.text_trim_size
      end
      if ActiveRecord::Base.connection.column_exists?(:messenger_settings, :supress_empty_messages)
        new_setting.supress_empty_messages = setting.supress_empty_messages
      end
      new_setting.save!
    end
  end
end
