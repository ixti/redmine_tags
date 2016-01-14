module RedmineTags
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def issue_tags
          @name = params[:q].to_s
          @tags = Issue.available_tags project: @project, name_like: @name
          render layout: false, partial: 'tag_list'
        end

        def wiki_tags
          @name = params[:q].to_s
          @tags = WikiPage.available_tags project: @project, name_like: @name
          render layout: false, partial: 'tag_list'
        end
      end
    end
  end
end

base = AutoCompletesController
patch = RedmineTags::Patches::AutoCompletesControllerPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
