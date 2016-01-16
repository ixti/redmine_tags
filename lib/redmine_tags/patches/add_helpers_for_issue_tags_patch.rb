module RedmineTags
  module Patches
    module AddHelpersForIssueTagsPatch
      def self.included(base)
        base.class_eval do
          helper IssuesTagsHelper
          helper TagsHelper
        end
      end
    end
  end
end

bases = [
  IssuesController,
  CalendarsController,
  GanttsController,
  SettingsController
]
patch = RedmineTags::Patches::AddHelpersForIssueTagsPatch
bases.each do |base|
  base.send(:include, patch) unless base.included_modules.include?(patch)
end
