module RedmineTags
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def tags
          Issue.available_tags project: self
        end
      end
    end
  end
end

base = Project
patch = RedmineTags::Patches::ProjectPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
