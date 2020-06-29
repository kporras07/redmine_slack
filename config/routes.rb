# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :projects, only: [] do
  resource :redmine_slack_setting, only: %i[show update]
end

post 'slack/slash/connect', :to => 'slash_commands#channel_connect'
