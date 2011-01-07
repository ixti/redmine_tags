module RedmineTags
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def issue_tags
          @tags = Issue.available_tags :project_id => @project
          render :layout => false, :partial => 'tag_list'
        end
      end
    end
  end
end
