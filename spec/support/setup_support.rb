module SetupSupport
  private

  def create_issue(project, tags, author, tracker, status, priority)
    issue = build(
      :issue,
      author:  author,
      priority: priority,
      project: project,
      status:  status,
      tracker: tracker
    )
    issue.tag_list = tags if tags.any?
    issue.save!
    if status.is_closed?
      issue.status = status
      issue.save!
    end
    issue
  end

  def create_base_setup
  end

  def create_base_setup_without_settings
    create_base_setup
    clear_plugin_settings
  end

  def create_base_setup_with_settings
    create_base_setup
    create_initial_settings
  end

  def clear_plugin_settings
    Setting.plugin_redmine_tags = nil
  end

  def create_initial_settings
    @selected_issues_sidebar    = 'List'
    @selected_issues_sort_by    = 'Name'
    @selected_issues_sort_order = 'Ascending'

    Setting.plugin_redmine_tags = ActionController::Parameters.new(
      issues_sidebar:    'list',
      issues_show_count: '1',
      issues_open_only:  '1',
      issues_sort_by:    'name',
      issues_sort_order: 'asc',
      issues_use_colors: '1'
    )
  end
end
