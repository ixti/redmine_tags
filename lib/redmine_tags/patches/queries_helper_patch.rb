# This file is a part of redmine_tags
# redMine plugin, that adds tagging support.
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

module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method :column_content_original, :column_content
          alias_method :column_content, :column_content_extended
        end
      end


      module InstanceMethods
        include TagsHelper


        # Returns link to the page with issues filtered by specified filters
        # === Parameters
        # * <i>title</i> = Link title text
        # * <i>filters</i> = Filters to be applied (see <tt>link_to_filter_options</tt> for details)
        # * <i>options</i> = (optional) Base options of the link
        # === Example
        # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]]
        # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]], :project_id => project
        def link_to_filter(title, filters, options = {})
          options.merge! link_to_filter_options(filters)
          link_to title, options
        end


        # Returns Hash suitable for passing it to the <tt>to_link</tt>
        # === Parameters
        # * <i>filters</i> = Array of arrays. Each child array is an array of strings:
        #                    name, operator and value
        # === Example
        # link_to 'foobar', link_to_filter_options [[ :tags, '~', 'foobar' ]]
        #
        # filters = [[ :tags, '~', 'bazbaz' ], [:status_id, 'o']]
        # link_to 'bazbaz', link_to_filter_options filters
        def link_to_filter_options(filters)
          options = {
            :controller => 'issues', :action => 'index', :set_filter => 1,
            :fields => [], :values => {}, :operators => {}
          }

          filters.each do |f|
            name, operator, value = f
            options[:fields].push name
            options[:operators][name] = operator
            options[:values][name] = [ value ]
          end

          options
        end


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
