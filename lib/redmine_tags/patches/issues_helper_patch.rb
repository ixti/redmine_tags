module RedmineTags
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          # See init.rb for explanation why TagsHelper is included here
          include TagsHelper
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def sidebar_tags
          unless @sidebar_tags
            @sidebar_tags = []
            if :none != redmine_tags_settings[:issues_sidebar].to_sym
              @sidebar_tags = Issue.available_tags(:project => @project,
                                                  :open_only => true || (redmine_tags_settings[:issues_open_only].to_i == 1))
            end
          end
          @sidebar_tags
        end

        def render_sidebar_tags
          render_tags_list(sidebar_tags,
                          :show_count => (redmine_tags_settings[:issues_show_count].to_i == 1),
                          :open_only => (redmine_tags_settings[:issues_open_only].to_i == 1),
                          :style => redmine_tags_settings[:issues_sidebar].to_sym)
        end
      end
    end
  end
end
