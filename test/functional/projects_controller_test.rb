require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets

  RedmineTags::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_tags).directory + '/test/fixtures/', [:taggings, :tags])

  include Redmine::I18n

  setup do
    User.current = User.find_by_login('admin')
  end

  test 'show action should not include tags when not explicitly specified' do
    get :show, params: { id: 1 }, as: :json
    api_response = JSON.parse(@response.body)['project']
    assert_response :success
    assert_not_nil api_response
    assert_nil api_response['tags']
  end

  test 'show action should include tags when requested' do
    get :show, params: { id: 1, include: 'tags' }, as: :json
    api_response = JSON.parse(@response.body)['project']
    assert_response :success
    assert_not_nil api_response
    assert_not_nil api_response['tags']
    assert_equal 5, api_response['tags'].length
  end

  test 'index should not include tags when not explicitly specified' do
    get :index, as: :json
    api_response = JSON.parse(@response.body)['projects']
    assert_response :success
    assert_not_nil api_response
    assert_not_empty api_response
    assert_nil api_response.first['tags']
    assert_nil api_response.last['tags']
  end

  test 'index should include own tags for each project' do
    tags_1 = ActsAsTaggableOn::Tag.where(name: ['Security', 'Production', 'Functional', 'Front End', 'Usability']).collect { |tag| {"id" => tag.id, "name" => tag.name} }
    get :index, params: { include: 'tags' }, as: :json
    api_response = JSON.parse(@response.body)['projects']
    assert_response :success
    assert_not_nil api_response
    api_project_1 = api_response.detect { |p| p["id"] == 1 }
    api_tags_1 = api_project_1['tags']
    assert_equal tags_1.map{|t| t['id']}.sort, api_tags_1.map{|t| t['id']}.sort
  end
end
