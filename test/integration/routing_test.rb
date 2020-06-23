# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

# Test Routing class.
class RoutingTest < Redmine::RoutingTest
  test 'routing redmine_slack' do
    should_route 'GET /projects/1/settings/redmine_slack' => 'projects#settings', :id => '1', :tab => 'redmine_slack'
    should_route 'PUT /projects/1/redmine_slack_setting' => 'redmine_slack_settings#update', :project_id => '1'
  end
end
