# frozen_string_literal: true

# To change this template, choose Tools | Templates
# and open the template in the editor.
module RedmineSlack
    module Patches
        class JournalsHook < Redmine::Hook::ViewListener
            # Add journal with edit issue
            def view_issues_edit_notes_bottom(context = {})
                issue = context[:issue]

                context[:controller].send(
                :render_to_string,
                partial: 'redmine_slack/journal_silent_updates', locals: {}
                )
            end
        end
    end
  end
