module RedmineTags
  module Patches
    module IssueImportPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :extend_object_without_tags, :extend_object
          alias_method :extend_object, :extend_object_with_tags
        end
        IssueImport::AUTO_MAPPABLE_FIELDS.store('tags', 'field_tags')
      end

      module InstanceMethods
        def extend_object_with_tags(row, item, issue)
          extend_object_without_tags(row, item, issue)

          if tags = row_value(row, 'tags')
            issue.tag_list = tags
            issue.save_tags
          end

          issue
        end
      end
    end
  end
end

base = IssueImport
patch = RedmineTags::Patches::IssueImportPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
