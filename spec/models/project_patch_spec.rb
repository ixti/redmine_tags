require 'spec_helper'

describe Project, type: :model do
  include SetupSupport

  it 'is patched with RedmineTags::Patches::ProjectPatch' do
    patch = RedmineTags::Patches::ProjectPatch
    expect(Project.included_modules).to include(patch)
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

  context '.tags' do
    before :example do
      allow(User).to receive(:current).and_return(author)
    end

    it 'returns an empty relation when no project issues exist' do
      result = project_1.tags
      expect(result).to be_an(ActiveRecord::Relation)
      expect(result).to eq([])
    end

    it 'returns an empty relation when no project issues have tags' do
      create_issue(project_1, [], author, tracker, status_open, priority)
      result = project_1.tags
      expect(result).to be_an(ActiveRecord::Relation)
      expect(result.to_a).to eq([])
    end

    it 'returns one tag when an project issue has one tag' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      result_scope = project_1.tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns one tag when many project issues have the same tag' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      result_scope = project_1.tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns all tags only once' do
      create_issue(project_1, %w[a b], author, tracker, status_open, priority)
      create_issue(project_1, %w[b c], author, tracker, status_open, priority)
      result_scope = project_1.tags
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
      result_scope = project_1.tags
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

    it 'returns tags regardless of type of status' do
      create_issue(project_1, %w[a], author, tracker, status_open, priority)
      create_issue(project_1, %w[b], author, tracker, status_closed, priority)
      result_scope = project_1.tags
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
      result_scope = project_1.tags(open_only: true)
      expect(result_scope).to be_an(ActiveRecord::Relation)
      result = result_scope.to_a
      expect(result.size).to eq(1)
      expect(result[0]).to be_an(ActsAsTaggableOn::Tag)
      expect(result[0].name).to eq('a')
    end

  end
end
