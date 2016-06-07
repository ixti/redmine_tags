module RedmineTags
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: 'issues/tags'
      render_on :view_issues_form_details_bottom, partial: 'issues/tags_form'
      render_on :view_issues_sidebar_planning_bottom, partial: 'issues/tags_sidebar'
    end
  end
end
