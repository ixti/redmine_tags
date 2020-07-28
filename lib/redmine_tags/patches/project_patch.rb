module RedmineTags
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def tags(options = {})
          Issue.available_tags options.merge(project: self)
        end
      end
    end
  end
end

base = Project
patch = RedmineTags::Patches::ProjectPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
