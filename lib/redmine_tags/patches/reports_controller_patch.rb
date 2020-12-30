module RedmineTags
  module Patches
    module ReportsControllerPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :issue_report_without_tags, :issue_report
          alias_method :issue_report, :issue_report_with_tags

          alias_method :issue_report_details_without_tags, :issue_report_details
          alias_method :issue_report_details, :issue_report_details_with_tags
        end
      end

      module InstanceMethods
        def tag_data
          with_subprojects = Setting.display_subprojects_issues?
          Issue.count_and_group_by(:project => @project, :association => :tags, :with_subprojects => with_subprojects)
        end

        def tag_rows
          Issue.available_tags.to_a
        end

        def issue_report_with_tags
          @issues_by_tags = tag_data
          @tags = tag_rows
          issue_report_without_tags
        end

        def issue_report_details_with_tags
          if params[:detail] == 'tag'
            @field = 'tag_id'
            @rows = tag_rows
            @data = tag_data
            @report_title = l(:field_tags)
          else
            issue_report_details_without_tags
          end
        end
      end
    end
  end
end

base = ReportsController
patch = RedmineTags::Patches::ReportsControllerPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
