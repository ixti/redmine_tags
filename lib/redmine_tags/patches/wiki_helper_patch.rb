
require_dependency 'wiki_helper'

module RedmineTags
  module Patches
    module WikiHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        include TagsHelper

        def sidebar_tags
          unless @sidebar_tags
            @sidebar_tags = []
            if :none != RedmineTags.settings[:issues_sidebar].to_sym
              @sidebar_tags = WikiPage.available_tags({
                :project => @project,
                :open_only => (RedmineTags.settings[:issues_open_only].to_i == 1)
              })
            end
          end
          @sidebar_tags
        end

        def render_sidebar_tags
          render_tags_list(sidebar_tags, {
            :show_count => (RedmineTags.settings[:issues_show_count].to_i == 1),
            :open_only => (RedmineTags.settings[:issues_open_only].to_i == 1),
            :style => RedmineTags.settings[:issues_sidebar].to_sym,
            :use_search => true
          })
        end
      end
    end
  end
end
