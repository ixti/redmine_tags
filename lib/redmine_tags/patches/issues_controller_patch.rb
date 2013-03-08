# patches IssuesController so that IssuesTagsHelper methods are available in
# views
module RedmineTags
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.send(:helper, 'issues_tags')
      end
    end
  end
end
