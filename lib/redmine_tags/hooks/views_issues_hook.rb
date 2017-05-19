module RedmineTags
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: 'issues/tags'
      render_on :view_issues_form_details_bottom, partial: 'issues/tags_form'
      render_on :view_issues_sidebar_planning_bottom, partial: 'issues/tags_sidebar'
      render_on :view_issues_bulk_edit_details_bottom, partial: 'issues/bulk_edit_tags'
      render_on :view_layouts_base_html_head, partial: 'tags/header_assets'
    end
  end
end
