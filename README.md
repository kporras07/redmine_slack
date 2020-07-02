Redmine Slack
=============

This plugin allows to send notifications from your Redmine installation to Slack.

It's heavily inspired by [Redmine Messenger](https://github.com/AlphaNodes/redmine_messenger/) but supporting only Slack. This way, we can take advantage of a lot of rich features included on Slack.

# Configuration

To configure this plugin you need to get Slack Verification Token and Slack Token.

## Slack Signing Secret

You get this on Basic Information tab for your app.

## Slack Token

You get this on "OAuth & Permissions" tab for your app.


There's a global config and a per-project config to override global values.

# Features

This plugin sends Slack notifications when you update issues or wiki entries.

To configure a new channel, you could do one of these options:

1) In Project -> Settings -> Redmine Slack, add channel and click save
2) In Slack channel, invoke slash command like this: `/redmine-connect project-slug`

