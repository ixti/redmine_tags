require 'spec_helper'

describe TagsController, type: :controller do
  include LoginSupport
  include SetupSupport
  render_views

  context 'with default settings' do
    let(:admin)         { create :user, :admin }
    let(:author)        { create :user }
    let(:role)          { create :role, :manager }
    let(:priority)      { create :issue_priority }
    let(:status_open)   { create :issue_status }
    let(:status_closed) { create :issue_status, is_closed: true }
    let(:tracker)       { create :tracker, default_status_id: status_open.id }
    let(:project_1) do
      project = create :project
      project.trackers = [tracker]
      project.save!
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
      project.save!
      member = create(
        :member,
        project_id: project.id,
        role_ids:   [role.id],
        user_id:    author.id
      )
      create :member_role, member_id: member.id, role_id: role.id
      project
    end

    before :example do
      login_as admin
      create_issue(project_1, %w{a1 a2}, author, tracker, status_open, priority)
      create_issue(project_1, %w{a2 a3}, author, tracker, status_open, priority)
      create_issue(project_1, %w{a4 a5}, author, tracker, status_closed, priority)
      create_issue(project_2, %w{b6 b7}, author, tracker, status_closed, priority)
      create_issue(project_2, %w{b8 b9}, author, tracker, status_open, priority)
    end

    it 'should get edit' do
      tag = ActsAsTaggableOn::Tag.where(name: 'a1').first
      get :edit, id: tag.id
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
      expect(assigns(:tag)).to eq(tag)
    end

    it 'should put update' do
      tag1 = ActsAsTaggableOn::Tag.where(name: 'a1').first
      old_name = tag1.name
      new_name = 'updated main'
      put :update, id: tag1.id, tag: { name: new_name }
      expect(response).to redirect_to(
          controller: 'settings',
          action: 'plugin',
          id: 'redmine_tags',
          tab: 'manage_tags'
        )
      tag1.reload
      expect(tag1.name).to eq(new_name)
    end

    it 'should delete destroy' do
      tag1 = ActsAsTaggableOn::Tag.where(name: 'a1').first
      expect do
        post :destroy, ids: tag1.id
        expect(response).to have_http_status(302)
      end.to change { ActsAsTaggableOn::Tag.count }.by(-1)
    end

    it 'should get merge' do
      tag1 = ActsAsTaggableOn::Tag.where(name: 'a1').first
      tag2 = ActsAsTaggableOn::Tag.where(name: 'b8').first
      get :merge, ids: [tag1.id, tag2.id]
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:merge)
      expect(assigns(:tags)).not_to be_nil
    end

    it 'should post merge' do
      tag1 = ActsAsTaggableOn::Tag.where(name: 'a1').first
      tag2 = ActsAsTaggableOn::Tag.where(name: 'b8').first
      expect do
        post :merge, ids: [tag1.id, tag2.id], tag: { name: 'a1' }
        expect(response).to redirect_to(
            controller: 'settings',
            action: 'plugin',
            id: 'redmine_tags',
            tab: 'manage_tags'
          )
      end.to change { ActsAsTaggableOn::Tag.count }.by(-1)
      expect(Issue.tagged_with('b8').count).to eq(0)
      expect(Issue.tagged_with('a1').count).to eq(2)
    end
  end
end
