# frozen_string_literal: true

# Redmine Slack module to add patches.
module RedmineSlack
  # Patches module.
  module Patches
    # Issue Patches.
    module IssuesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          before_action :handle_silent_update, :only => :update
        end
      end

      # Instance Methods.
      module InstanceMethods
        extend ActiveSupport::PerThreadRegistry
        def handle_silent_update
          RequestStore.store[:redmine_slack_silent] = params[:redmine_slack_silent]
        end

      end
    end
  end
end

# Add module to Welcome Controller
IssuesController.send(:include, RedmineSlack::Patches::IssuesControllerPatch)
IssuesController.prepend RedmineSlack::Patches::IssuesControllerPatch
