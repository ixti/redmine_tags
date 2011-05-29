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

module TagsHelper
  include ActsAsTaggableOn::TagsHelper

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


  # Returns tag link
  # === Parameters
  # * <i>tag</i> = Instance of Tag
  # * <i>options</i> = (optional) Options (override system settings)
  #   * show_count  - Boolean. Whenever show tag counts
  #   * open_only   - Boolean. Whenever link to the filter with "open" issues
  #                   only limit.
  def render_tag_link(tag, options = {})
    filters = [[:tags, '=', tag.name]]
    filters << [:status_id, 'o'] if options[:open_only]

    content = link_to_filter tag.name, filters, :project_id => @project
    if options[:show_count]
      content << content_tag('span', "(#{tag.count})", :class => 'tag-count')
    end

    content_tag('span', content, :class => 'tag-label')
  end

  # Renders list of tags
  # Clouds are rendered as block <tt>div</tt> with internal <tt>span</t> per tag.
  # Lists are rendered as unordered lists <tt>ul</tt>. Lists are ordered by
  # <tt>tag.count</tt> descending.
  # === Parameters
  # * <i>tags</i> = Array of Tag instances
  # * <i>options</i> = (optional) Options (override system settings)
  #   * show_count  - Boolean. Whenever show tag counts
  #   * open_only   - Boolean. Whenever link to the filter with "open" issues
  #                   only limit.
  #   * style       - list, cloud
  def render_tags_list(tags, options = {})
    unless tags.nil? or tags.empty?
      content, style = '', options.delete(:style)
    
      tags.sort! { |a,b| b.count <=> a.count }

      if :list == style
        list_el, item_el = 'ul', 'li'
      elsif :cloud == style
        list_el, item_el = 'div', 'span'
        tags = cloudify(tags)
      else
        raise "Unknown list style"
      end

      tag_cloud tags, (1..8).to_a do |tag, weight|
        content << " " + content_tag(item_el, render_tag_link(tag, options), :class => "tag-nube-#{weight}") + " "
      end

      content_tag(list_el, content, :class => 'tags')
    end
  end

  def redmine_tags_settings
    @redmine_tags_settings = Setting.plugin_redmine_tags unless @redmine_tags_settings
    @redmine_tags_settings
  end

  private
  # put most massive tags in the middle
  def cloudify(tags)
    temp, tags, trigger = tags, [], true
    temp.each do |tag|
      tags.send((trigger ? 'push' : 'unshift'), tag)
      trigger = !trigger
    end
    tags
  end

end
