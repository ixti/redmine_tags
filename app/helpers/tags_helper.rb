require 'digest/md5'

module TagsHelper
  include ActsAsTaggableOn::TagsHelper
  include FiltersHelper

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
    if options[:use_search]
      content = link_to tag, { controller: 'search', action: 'index',
        id: @project, q: tag.name, wiki_pages: true, issues: true }
    else
      content = link_to_filter tag.name, filters, project_id: @project
    end
    if options[:show_count]
      content << content_tag('span', "(#{ tag.count })", class: 'tag-count')
    end
    style = if RedmineTags.settings[:issues_use_colors].to_i > 0
        { class: 'tag-label-color',
          style: "background-color: #{ tag_color tag }" }
      else
        { class: 'tag-label' }
      end
    content_tag 'span', content, style
  end

  def tag_color(tag)
    tag_name = tag.respond_to?(:name) ? tag.name : tag
    "##{ Digest::MD5.hexdigest(tag_name)[0..5] }"
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
      # prevent ActsAsTaggableOn::TagsHelper from calling `all`
      # otherwise we will need sort tags after `tag_cloud`
      tags = tags.to_a
      case sorting = "#{ RedmineTags.settings[:issues_sort_by] }:#{ RedmineTags.settings[:issues_sort_order] }"
        when 'name:asc'
          tags.sort! {|a, b| a.name <=> b.name }
        when 'name:desc'
          tags.sort! {|a, b| b.name <=> a.name }
        when 'count:asc'
          tags.sort! {|a, b| a.count <=> b.count }
        when 'count:desc'
          tags.sort! {|a, b| b.count <=> a.count }
        else
          # Unknown sorting option. Fallback to default one
          logger.warn "[redmine_tags] Unknown sorting option: <#{ sorting }>"
          tags.sort! {|a, b| a.name <=> b.name }
      end
      if :list == style
        list_el, item_el = 'ul', 'li'
      elsif :simple_cloud == style
        list_el, item_el = 'div', 'span'
      elsif :cloud == style
        list_el, item_el = 'div', 'span'
        tags = cloudify tags
      else
        raise 'Unknown list style'
      end
      content = content.html_safe
      tag_cloud tags, (1..8).to_a do |tag, weight|
        content << ' '.html_safe <<
          content_tag(item_el, render_tag_link(tag, options),
            class: "tag-nube-#{ weight }",
            style: (:simple_cloud == style ? 'font-size: 1em;' : '')) <<
          ' '.html_safe
      end
      content_tag list_el, content, class: 'tags',
        style: (:simple_cloud == style ? 'text-align: left;' : '')
    end
  end

  private

  # make snowball. first tags comes in th middle.
  def cloudify(tags)
    temp, tags, trigger = tags, [], true
    temp.each do |tag|
      tags.send (trigger ? 'push' : 'unshift'), tag
      trigger = !trigger
    end
    tags
  end
end
