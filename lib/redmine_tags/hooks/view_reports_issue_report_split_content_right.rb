module RedmineTags
  module Hooks
    class ViewReportsIssueReportSplitContentRightHook < Redmine::Hook::ViewListener
      render_on :view_reports_issue_report_split_content_right, partial: 'issue_report_with_tags'
    end
  end
end
