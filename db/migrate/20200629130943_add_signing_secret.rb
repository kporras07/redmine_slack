class AddSigningSecret < ActiveRecord::Migration[5.2]
  def change
    add_column :redmine_slack_settings, :redmine_slack_signing_secret, :string
    remove_column :redmine_slack_settings, :redmine_slack_verification_token
  end
end
