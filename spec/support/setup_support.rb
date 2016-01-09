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
end
