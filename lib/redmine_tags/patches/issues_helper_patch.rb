
require_dependency 'issues_helper'

module RedmineTags
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        include TagsHelper

        def sidebar_tags_issues
          unless @sidebar_tags
            @sidebar_tags = []
            if :none != RedmineTags.settings[:issues_sidebar].to_sym
              @sidebar_tags = Issue.available_tags({
                :project => @project,
                :open_only => (RedmineTags.settings[:issues_open_only].to_i == 1)
              })
            end
          end
          @sidebar_tags
        end

        def render_sidebar_tags_issues
          render_tags_list(sidebar_tags_issues, {
            :show_count => (RedmineTags.settings[:issues_show_count].to_i == 1),
            :open_only => (RedmineTags.settings[:issues_open_only].to_i == 1),
            :style => RedmineTags.settings[:issues_sidebar].to_sym
          })
        end
      end
    end
  end
end
