module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :column_content_without_redmine_tags, :column_content
          alias_method :column_content, :column_content_with_redmine_tags

          alias_method :csv_content_without_redmine_tags, :csv_content
          alias_method :csv_content, :csv_content_with_redmine_tags
        end
      end

      module InstanceMethods
        include TagsHelper

        def column_content_with_redmine_tags(column, issue)
          if column.name == :tags
            column.value(issue).collect{ |t| render_tag_link(t) }
              .join(RedmineTags.settings[:issues_use_colors].to_i > 0 ? ' ' : ', ').html_safe
          else
            column_content_without_redmine_tags(column, issue)
          end
        end

        def csv_content_with_redmine_tags(column, issue)
          value = column.value_object(issue)
          if column.name == :tags
            value.collect {|v| csv_value(column, issue, v)}.compact.join(', ').html_safe
          else
            csv_content_without_redmine_tags(column, issue)
          end
        end
      end
    end
  end
end

base = QueriesHelper
patch = RedmineTags::Patches::QueriesHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
