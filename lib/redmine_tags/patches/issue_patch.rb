module RedmineTags
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          acts_as_taggable
        end
      end

      module ClassMethods
        def available_tags(options)
          Issue.tag_counts
        end
      end

      module InstanceMethods
      end
    end
  end
end
