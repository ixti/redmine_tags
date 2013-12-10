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

require_dependency 'queries_helper'
if ActiveSupport::Dependencies::search_for_file('issue_queries_helper')
  require_dependency 'issue_queries_query'
end

module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method :column_content_original, :column_content
          alias_method :column_content, :column_content_extended
        end
      end


      module InstanceMethods
        include TagsHelper


        def column_content_extended(column, issue)
          if column.name.eql? :tags
            column.value(issue).collect{ |t| render_tag_link(t) }.join(', ')
          else
            column_content_original(column, issue)
          end
        end
      end
    end
  end
end
