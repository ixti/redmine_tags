module IssuesTagsHelper
  def sidebar_tags
    unless @sidebar_tags
      @sidebar_tags = []
      if :none != RedmineTags.settings[:issues_sidebar].to_sym
        @sidebar_tags = Issue.available_tags project: @project,
          open_only: (RedmineTags.settings[:issues_open_only].to_i == 1)
      end
    end
    @sidebar_tags
  end

  def render_sidebar_tags
    render_tags_list sidebar_tags, {
      show_count: (RedmineTags.settings[:issues_show_count].to_i == 1),
      open_only: (RedmineTags.settings[:issues_open_only].to_i == 1),
      style: RedmineTags.settings[:issues_sidebar].to_sym }
  end

  def issue_tags_check_box_tags(name, issue_tags)
    s = ""
    issue_tags.each do |issue_tag|
      s << "<label>#{ check_box_tag name, issue_tag.id, false, :id => nil } #{h issue_tag}</label>\n"
    end
    s.html_safe
  end
end
