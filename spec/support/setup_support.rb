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
    issue.tag_list = tags
    issue.save!
    issue
  end
end
