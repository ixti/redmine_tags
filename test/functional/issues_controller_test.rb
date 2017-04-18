require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
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

  def setup
    User.current = nil
  end

  def test_show_issue_should_display_tags
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success

    assert_select 'div.tags .value span.tag-label a', 1, :text => 'Security'
  end

  def test_show_issue_should_display_multiple_tags
    @request.session[:user_id] = 1
    get :show, :id => 3
    assert_response :success

    assert_select 'div.tags .value', :text => 'Security, Production'
    assert_select 'div.tags .value' do
      assert_select 'span.tag-label', 2, :text
      assert_select 'span.tag-label a', :text => 'Security'
      assert_select 'span.tag-label a', :text => 'Production'
    end
  end

  def test_show_issue_should_display_tags
    @request.session[:user_id] = 1
    get :show, :id => 3
    assert_response :success

    assert_select 'div.tags .value', :text => 'Security, Production' do
      assert_select 'span.tag-label', 2, :text
      assert_select 'span.tag-label a', :text => 'Security'
      assert_select 'span.tag-label a', :text => 'Production'
    end
  end

  def test_show_issue_should_not_display_tags_if_not_exists
    @request.session[:user_id] = 1
    get :show, :id => 10
    assert_response :success

    assert_select 'div.tags', 0
  end

  def test_get_bulk_edit_should_display_only_common_tags
    @request.session[:user_id] = 2
    get :bulk_edit, :ids => [1, 3]
    assert_response :success

    assert_select 'input[type=hidden][name=?][value=?]', 'common_tags', 'Security'
    assert_select 'input[name=?][value=?]', 'issue[tag_list]', 'Security'
  end

  def test_get_bulk_edit_should_not_display_tags_for_issues_without_common_tags
    @request.session[:user_id] = 2
    get :bulk_edit, :ids => [1, 5]
    assert_response :success

    assert_select 'input[type=hidden][name=?][value=?]', 'common_tags', ''
    assert_select 'input[name=?][value=?]', 'issue[tag_list]', ''
  end
end
