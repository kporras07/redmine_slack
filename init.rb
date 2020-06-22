raise "\n\033[31mredmine_redmine_slack requires ruby 2.3 or newer. Please update your ruby version.\033[0m" if RUBY_VERSION < '2.3'

require 'redmine'
require 'redmine_slack'

Redmine::Plugin.register :redmine_slack do
  name 'Redmine Slack plugin'
  author 'Kevin Porras'
  description 'Plugin to send notifications of Redmine updates to Slack channels.'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  requires_redmine version_or_higher: '3.0.0'

  permission :manage_redmine_slack, projects: :settings, redmine_slack_settings: :update

  settings default: {
    redmine_slack_url: '',
    redmine_slack_channel: 'redmine',
    redmine_slack_verify_ssl: '1',
    auto_mentions: '0',
    default_mentions: '',
    post_updates: '1',
    new_include_description: '1',
    updated_include_description: '1',
    text_trim_size: '0',
    supress_empty_messages: '1',
    post_private_issues: '0',
    post_private_notes: '0',
    post_wiki: '0',
    post_wiki_updates: '0',
  }, partial: 'settings/redmine_slack_settings'
end
