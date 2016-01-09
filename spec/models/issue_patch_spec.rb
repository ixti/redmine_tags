require 'spec_helper'

describe Issue, type: :model do
  include SetupSupport

  it 'is patched with RedmineTags::Patches::IssuePatch' do
    patch = RedmineTags::Patches::IssuePatch
    expect(Issue.included_modules).to include(patch)
  end

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

  context 'with default settings' do
    let(:author)        { create :user }
    let(:priority)      { create :issue_priority }
    let(:status_open)   { create :issue_status }
    let(:status_closed) { create :issue_status, is_closed: true }
    let(:tracker)       { create :tracker, default_status_id: status_open.id }
    let(:project_1) do
      project = create :project
      project.trackers = [tracker]
      project.save
      project
    end
    let(:project_2) do
      project = create :project
      project.trackers = [tracker]
      project.save
      project
    end

    before :example do
      allow(User).to receive(:current).and_return(author)
      create_issues_with_tags
    end

    it 'returns a list of distinct tags' do
      expect(Issue.available_tags.size).to eq(9)
    end

    it 'allows listing tags of open issues only' do
      expect(Issue.available_tags(open_only: true).size).to eq(5)
    end

    it 'allows listing tags of specific project only' do
      expect(Issue.available_tags(project: project_1).size).to eq(5)
      expect(Issue.available_tags(project: project_2).size).to eq(4)
      expect(Issue.available_tags(open_only: true, project: project_1).size).to eq(3)
      expect(Issue.available_tags(open_only: true, project: project_2).size).to eq(2)
    end

    it 'allows listing tags found by name' do
      expect(Issue.available_tags(name_like: 'a').size).to eq(5)
      expect(Issue.available_tags(name_like: 'b').size).to eq(4)
      expect(Issue.available_tags(name_like: 'a1').size).to eq(1)
      expect(Issue.available_tags(name_like: 'a2').size).to eq(1)

      expect(Issue.available_tags(name_like: 'a', project: project_1).size).to eq(5)
      expect(Issue.available_tags(name_like: 'b', project: project_1).size).to eq(0)
      expect(Issue.available_tags(name_like: 'a', open_only: true, project: project_1).size).to eq(3)
      expect(Issue.available_tags(name_like: 'b', open_only: true, project: project_1).size).to eq(0)
    end
  end
end
