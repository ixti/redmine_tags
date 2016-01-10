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
end
