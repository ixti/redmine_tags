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

  def test_index_displays_tags_as_html_in_the_correct_column
    @request.session[:user_id] = 1

    with_settings :issue_list_default_columns => ['tags'] do
      get :index
    end

    assert_response :success

    assert_select 'table.issues' do
      assert_select 'thead' do
        assert_select 'th', :text => 'Tags'
      end

      assert_select 'tbody' do
        assert_select 'tr' do
          assert_select 'td.tags' do
            assert_select 'span.tag-label' do
              assert_select 'a'
            end
          end
        end
      end
    end
  end

  def test_show_issue_should_not_display_tags_if_not_exists
    @request.session[:user_id] = 1
    get :show, :params => {
      :id => 10
    }

    assert_response :success

    assert_select 'div.tags', 0
  end

  def test_show_issue_should_display_tags
    @request.session[:user_id] = 1
    get :show, :params => {
      :id => 1
    }
    assert_response :success

    assert_select 'div.tags .value span.tag-label a', 1, :text => 'Security'
  end

  def test_show_issue_should_display_multiple_tags
    @request.session[:user_id] = 1
    get :show, :params => {
      :id => 3
    }
    assert_response :success

#    assert_select 'div.tags .value', :text => 'Security, Production'
    assert_select 'div.tags .value' do
      assert_select 'span.tag-label', 2, :text
      assert_select 'span.tag-label a', :text => 'Security'
      assert_select 'span.tag-label a', :text => 'Production'
    end

    assert_select 'input[name=?][value=?]', 'issue[tag_list]', 'Security, Production'
  end

  def test_show_issue_should_display_contrast_tag_colors
    Setting.plugin_redmine_tags[:issues_use_colors] = '1'
    @request.session[:user_id] = 1
    get :show, :params => {
      :id => 7
    }
    assert_response :success

    assert_select 'div.tags .value' do
      assert_select 'span.tag-label-color', 2, :text
      assert_select "span.tag-label-color[style*=?]", "color: white", :text => "Front End"
      assert_select "span.tag-label-color[style*=?]", "background-color: #f1253f", :text => "Front End"
      assert_select "span.tag-label-color[style*=?]", "color: black", :text => "Usability"
      assert_select "span.tag-label-color[style*=?]", "background-color: #16d103", :text => "Usability"
    end

    assert_select 'input[name=?][value=?]', 'issue[tag_list]', 'Front End, Usability'
    Setting.plugin_redmine_tags[:issues_use_colors] = '0'
  end

  def test_edit_issue_tags_should_journalize_changes
    @request.session[:user_id] = 1
    put :update, :params => {
      :id => 3, :issue => { :tag_list => 'Security' }
    }

    assert_redirected_to :action => 'show', :id => '3'

    issue = Issue.find(3)
    journals = issue.journals
    journal_details = journals.first.details

    assert_equal ['Security'], issue.tag_list
    assert_equal 1, journals.count
    assert_equal 1, journal_details.count
    assert_equal 'Security, Production', journal_details.first.old_value
    assert_equal 'Security', journal_details.first.value
  end

  def test_get_bulk_edit_should_display_only_common_tags
    @request.session[:user_id] = 2
    get :bulk_edit,  :params => {
      :ids => [1, 3]
    }
    assert_response :success

    assert_select 'input[type=hidden][name=?][value=?]', 'common_tags', 'Security'
    assert_select 'input[name=?][value=?]', 'issue[new_tag_list]', 'Security'
  end

  def test_get_bulk_edit_should_not_display_tags_for_issues_without_common_tags
    @request.session[:user_id] = 2
    get :bulk_edit,  :params => {
      :ids => [1, 3, 4]
    }
    assert_response :success

    assert_select 'input[type=hidden][name=?][value=?]', 'common_tags', ''
    assert_select 'input[name=?][value=?]', 'issue[new_tag_list]', ''
  end

  def test_bulk_edit_with_no_common_tags_and_add_new_tag
    @request.session[:user_id] = 2
    post :bulk_update,  :params => {
      :ids => [5, 6],
      :issue => {
          :new_tag_list => 'Production'
        },
      :common_tags => ''
    }
    assert_response 302

    assert_equal ['Functional', 'Production'], Issue.find(5).tag_list
    assert_equal ['Front End', 'Production'], Issue.find(6).tag_list
  end


  def test_bulk_edit_with_common_tags_and_new_add_tag
    @request.session[:user_id] = 2
    post :bulk_update,  :params => {
      :ids => [3, 4],
      :issue => {
        :new_tag_list => 'Production, Functional'
      },
      :common_tags => 'Production'
    }

    assert_response 302

    assert_equal ['Production', 'Functional'], Issue.find(4).tag_list
    assert_equal [ 'Security', 'Production', 'Functional'], Issue.find(3).tag_list
  end

  def test_bulk_edit_with_no_common_tags_add_same_tag
    @request.session[:user_id] = 2
    post :bulk_update,  :params => {
      :ids => [1, 4],
      :issue => {
        :new_tag_list => 'Security'
      },
      :common_tags => ''
    }
    assert_response 302

    assert_equal ['Security'], Issue.find(1).tag_list
    assert_equal ['Production', 'Security'], Issue.find(4).tag_list
  end

  def test_bulk_edit_with_common_tag_and_remove_common_tag
    @request.session[:user_id] = 2
    post :bulk_update,  :params => {
      :ids => [3, 4, 6],
      :issue => {
        :new_tag_list => ''
      },
      :common_tags => 'Production'
    }
    assert_response 302

    assert_equal ['Security'], Issue.find(3).tag_list
    assert_equal [], Issue.find(4).tag_list
    assert_equal ['Front End'], Issue.find(6).tag_list
  end

  def test_bulk_edit_journal_without_tag_changing
    # journal should not log tags changing when tags were not changed
    @request.session[:user_id] = 2
    post :bulk_update, :params => {
         :ids => [2, 7],
         :issue => {
           :new_tag_list => '',
           :priority_id => 7
         },
         :common_tags => ''
     }
    assert_response 302

    assert_equal ['priority_id'], Issue.find(2).journals.last.details.map(&:prop_key)
    assert_equal ['priority_id'], Issue.find(7).journals.last.details.map(&:prop_key)
    assert_equal 7, Issue.find(2).priority_id
    assert_equal 7, Issue.find(7).priority_id
  end

  def test_bulk_edit_journal_with_tag_changing
    # journal should log tags changing when tags were changed
    @request.session[:user_id] = 2
    post :bulk_update, :params => {
         :ids => [2, 7],
         :issue => {
           :new_tag_list => ['Production', 'Security']
         }
       }
    assert_response 302

    assert_equal ['tag_list'], Issue.find(2).journals.last.details.map(&:prop_key)
    assert_equal ['tag_list'], Issue.find(7).journals.last.details.map(&:prop_key)
  end
end
