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

require_dependency 'auto_completes_controller'

module RedmineTags
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
        end
      end


      module InstanceMethods
        def issue_tags
          @name = params[:q].to_s
          @tags = Issue.available_tags({
            :project_id => @project,
            :name_like => @name
          })
          render :layout => false, :partial => 'tag_list'
        end

        def wiki_tags
          @name = params[:q].to_s
          @tags = WikiPage.available_tags({
            :project_id => @project,
            :name_like => @name
          })
          render :layout => false, :partial => 'tag_list'
        end
      end
    end
  end
end
