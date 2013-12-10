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

module FiltersHelper
  # returns link to the page with issues filtered by specified filters
  # === parameters
  # * <i>title</i> = link title text
  # * <i>filters</i> = filters to be applied (see <tt>link_to_filter_options</tt> for details)
  # * <i>options</i> = (optional) base options of the link
  # === example
  # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]]
  # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]], :project_id => project
  def link_to_filter(title, filters, options = {})
    options.merge! link_to_filter_options(filters)
    link_to title, options
  end


  # returns hash suitable for passing it to the <tt>to_link</tt>
  # === parameters
  # * <i>filters</i> = array of arrays. each child array is an array of strings:
  #                    name, operator and value
  # === example
  # link_to 'foobar', link_to_filter_options [[ :tags, '~', 'foobar' ]]
  #
  # filters = [[ :tags, '~', 'bazbaz' ], [:status_id, 'o']]
  # link_to 'bazbaz', link_to_filter_options filters
  def link_to_filter_options(filters)
    options = {
      :controller => 'issues',
      :action => 'index',
      :set_filter => 1,
      :fields => [],
      :values => {},
      :operators => {}
    }

    filters.each do |f|
      name, operator, value = f
      options[:fields].push(name)
      options[:operators][name] = operator
      options[:values][name] = [value]
    end

    options
  end
end
