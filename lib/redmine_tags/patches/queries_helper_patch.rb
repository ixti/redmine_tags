module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :column_content_original, :column_content
          alias_method :column_content, :column_content_extended
        end
      end

      module InstanceMethods
        include TagsHelper

        def column_content_extended(column, issue)
          if column.name.eql? :tags
            column.value(issue).collect{ |t| render_tag_link(t) }
              .join(RedmineTags.settings[:issues_use_colors].to_i > 0 ? ' ' : ', ')
          else
            column_content_original column, issue
          end
        end
      end
    end
  end
end

base = QueriesHelper
patch = RedmineTags::Patches::QueriesHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
