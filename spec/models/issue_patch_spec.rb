require 'spec_helper'

describe Issue, type: :model do
  include SetupSupport

  it 'is patched with RedmineTags::Patches::IssuePatch' do
    patch = RedmineTags::Patches::IssuePatch
    expect(Issue.included_modules).to include(patch)
  end

  let(:author)        { create :user }
  let(:role)          { create :role, :manager }
  let(:priority)      { create :issue_priority }
  let(:status_open)   { create :issue_status }
  let(:status_closed) { create :issue_status, is_closed: true }
  let(:tracker)       { create :tracker, default_status_id: status_open.id }
  let(:project_1) do
    project = create :project
    project.trackers = [tracker]
    project.save
    member = create(
      :member,
      project_id: project.id,
      role_ids:   [role.id],
      user_id:    author.id
    )
    create :member_role, member_id: member.id, role_id: role.id
    project
  end
  let(:project_2) do
    project = create :project
    project.trackers = [tracker]
    project.save
    member = create(
      :member,
      project_id: project.id,
      role_ids:   [role.id],
      user_id:    author.id
    )
    create :member_role, member_id: member.id, role_id: role.id
    project
  end

  context '.available_tags' do
    before :example do
      allow(User).to receive(:current).and_return(author)
    end

    it 'returns an empty relation when no issues exist' do
      result = Issue.available_tags
      expect(result).to be_an(ActiveRecord::Relation)
      expect(result).to eq([])
    end

    it 'returns an empty relation when no issues have tags' do
      create_issue(project_1, [], author, tracker, status_open, priority)
      result = Issue.available_tags
      expect(result).to be_an(ActiveRecord::Relation)
      expect(result.to_a).to eq([])
    end

    it 'returns one tag when an issue has one tag' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      result_scope = Issue.available_tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns one tag when manny issues have the same tag' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      result_scope = Issue.available_tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns all tags only once ' do
      create_issue(project_1, %w[a b], author, tracker, status_open, priority)
      create_issue(project_1, %w[b c], author, tracker, status_open, priority)
      result_scope = Issue.available_tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(3)
      result.each_with_index do |tag, index|
        expect(tag).to be_an(ActsAsTaggableOn::Tag)
        expect(%w[a b c]).to include(tag.name)
      end
    end

    it 'returns tags for a specific project' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_2, %w[c], author, tracker, status_open, priority)
      result_scope = Issue.available_tags(project: project_1)
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns tags regardless of type of status' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_1, %w[b], author, tracker, status_closed, priority)
      result_scope = Issue.available_tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a.uniq
      expect(result.size).to eq(2)
      result.each_with_index do |tag, index|
        expect(tag).to be_an(ActsAsTaggableOn::Tag)
        expect(%w[a b]).to include(tag.name)
      end
    end

    it 'returns tags only for open issues when open_only: true' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_1, %w[b], author, tracker, status_closed, priority)
      result_scope = Issue.available_tags(open_only: true)
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns tags fitered by name' do
      create_issue(project_1, %w[a1], author, tracker, status_open, priority)
      create_issue(project_1, %w[a2 b1], author, tracker, status_open, priority)
      result_scope = Issue.available_tags(name_like: 'a')
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(2)
      result.each_with_index do |tag, index|
        expect(tag).to be_an(ActsAsTaggableOn::Tag)
        expect(%w[a1 a2]).to include(tag.name)
      end
    end

    it 'returns tags fitered by name for open issues' do
      create_issue(project_1, %w[a1], author, tracker, status_open, priority)
      create_issue(project_1, %w[a2], author, tracker, status_closed, priority)
      result_scope = Issue.available_tags(name_like: 'a', open_only: true)
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a1')
    end

    it 'returns tags fitered by name for open issues and specific project' do
      create_issue(project_1, %w[a1], author, tracker, status_open, priority)
      create_issue(project_1, %w[a2], author, tracker, status_closed, priority)
      create_issue(project_2, %w[a3], author, tracker, status_open, priority)
      result_scope = Issue.available_tags(
        name_like: 'a',
        open_only: true,
        project:   project_1
      )
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a1')
    end
  end

  context '.remove_unused_tags!' do
  end

  context '.specific_tag_counts' do
  end

  context '#copy_from_with_redmine_tags' do
  end
end
