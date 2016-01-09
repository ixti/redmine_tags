module SetupSupport
  private

  def create_issue(project, tags, author, tracker, status)
    issue = build(
      :issue,
      project: project,
      author:  author,
      tracker: tracker,
      status:  status
    )
    issue.tag_list = tags
    issue.save
    issue
  end

  def create_issues_with_tags
    create_issue(project_1, %w{a1 a2}, author, tracker, status_open)
    create_issue(project_1, %w{a2 a3}, author, tracker, status_open)
    create_issue(project_1, %w{a4 a5}, author, tracker, status_closed)
    create_issue(project_2, %w{b6 b7}, author, tracker, status_closed)
    create_issue(project_2, %w{b8 b9}, author, tracker, status_open)
  end
end
