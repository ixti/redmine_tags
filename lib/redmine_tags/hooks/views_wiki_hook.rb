# This file is a part of redmine_tags
# Redmine plugin, that adds tagging support.
#
# Copyright (c) 2010 Aleksey V Zapparov AKA ixti
#
# redmine_tags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_tags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.

module RedmineTags
  module Hooks
    class ViewsWikiHook < Redmine::Hook::ViewListener

       def view_layouts_base_body_bottom(context= { })
         controller = context[:controller]
         action = controller.action_name
         request = context[:request]

         hook_res = ''
         if controller.is_a?(WikiController)
           context[:page] = controller.instance_variable_get("@page")
           return '' unless context[:page]
	   if action == 'show'
             hook_res = view_wiki_show_bottom(context)
             scripts = ''
             hook_res.scan(/<script.*<\/script>/m) { |m| scripts += m}
             hook_res.gsub!(/<script.*<\/script>/m, ' ')
             hook_res.gsub!(/\n/, " \\\n")
             hook_res = javascript_tag "$('div.wiki').after('#{hook_res}')"
             hook_res += scripts.html_safe
           elsif action == 'edit'
             hook_res = view_wiki_form_bottom(context)
             scripts = ''
             hook_res.scan(/<script.*<\/script>/m) { |m| scripts += m}
             hook_res.gsub!(/<script.*<\/script>/m, ' ')
             hook_res.gsub!(/\n/, " \\\n")
             hook_res = javascript_tag "$('#content_comments').parent().after('#{hook_res}')"
             hook_res += scripts.html_safe
           end
         end

         return hook_res
       end


      # Why wiki doesnt have this hooks? :(

      def view_wiki_show_bottom(context= { })
        context[:controller].send(:render_to_string, {
          :partial => "wiki/tags",
          :locals => {:page => context[:page]}
        })
      end

      def view_wiki_form_bottom(context= { })
        context[:controller].send(:render_to_string, {
          :partial => "wiki/tags_form",
          :locals => {:page => context[:page]}
        })
      end

      def view_layouts_base_sidebar(context= { })
        controller = context[:controller]
        action = controller.action_name
        if controller.is_a?(WikiController) &&
           (action == 'index' || action == 'show' || action == 'date_index')
          return context[:controller].send(:render_to_string, {
            :partial => "wiki/tags_sidebar",
            :locals => {:page => context[:page]}
          })
        end
        return ''
      end

#      render_on :view_issues_form_details_bottom, :partial => 'issues/tags_form'
#      render_on :view_issues_sidebar_planning_bottom, :partial => 'issues/tags_sidebar'
#      render_on :view_issues_bulk_edit_details_bottom, :partial => 'issues/tags_form'
    end
  end
end

