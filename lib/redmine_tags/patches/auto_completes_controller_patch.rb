module RedmineTags
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.class_eval do
          helper TagsHelper
        end
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def issue_tags
          @name = params[:q].to_s
          @tags = Issue.available_tags project: @project, name_like: @name
          if params[:object_type] == 'issue' && params[:object_id] && issue = Issue.find_by(id: params[:object_id])
            @tags -= issue.tags
          end
          render layout: false, partial: params[:partial] || 'tag_list', locals: {tags: @tags}
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
