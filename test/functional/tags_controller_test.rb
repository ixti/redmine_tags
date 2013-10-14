require File.expand_path('../../test_helper', __FILE__)      

class TagsControllerTest < ActionController::TestCase  
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
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
           :custom_fields_trackers
         
  
  def setup
    # run as the admin
    @request.session[:user_id] = 1

    @project_a = Project.generate!
    @project_b = Project.generate!

    add_issue @project_a, %w{a1 a2}, false
    add_issue @project_a, %w{a2 a3}, false
    add_issue @project_a, %w{a4 a5}, true
    add_issue @project_b, %w{b6 b7}, true
    add_issue @project_b, %w{b8 b9}, false
  end

  test "should get edit" do 
    @request.session[:user_id] = 1
    tag = ActsAsTaggableOn::Tag.find_by_name("a1")
    get :edit, :id => tag.id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:tag)
    assert_equal tag, assigns(:tag)
  end

  test "should put update" do 
    @request.session[:user_id] = 1
    tag1 = ActsAsTaggableOn::Tag.find_by_name("a1")
    old_name = tag1.name
    new_name = "updated main"
    put :update, :id => tag1.id, :tag => {:name => new_name}
    assert_redirected_to :controller => 'settings', :action => 'plugin', :id => "redmine_tags", :tab => "manage_tags"
    tag1.reload
    assert_equal new_name, tag1.name 
  end  

  test "should delete destroy" do
    @request.session[:user_id] = 1
    tag1 = ActsAsTaggableOn::Tag.find_by_name("a1")
    assert_difference 'ActsAsTaggableOn::Tag.count', -1 do
      post :destroy, :ids => tag1.id
      assert_response 302
    end
  end    


  test "should get merge" do
    tag1 = ActsAsTaggableOn::Tag.find_by_name("a1")
    tag2 = ActsAsTaggableOn::Tag.find_by_name("b8")
    get :merge, :ids => [tag1.id, tag2.id]
    assert_response :success
    assert_template 'merge'
    assert_not_nil assigns(:tags)
  end    

  test "should post merge" do
    tag1 = ActsAsTaggableOn::Tag.find_by_name("a1")
    tag2 = ActsAsTaggableOn::Tag.find_by_name("b8")
    assert_difference 'ActsAsTaggableOn::Tag.count', -1 do
      post :merge, :ids => [tag1.id, tag2.id], :tag => {:name => "a1"}
      assert_redirected_to :controller => 'settings', :action => 'plugin', :id => "redmine_tags", :tab => "manage_tags"
    end
    assert_equal 0, Issue.tagged_with("b8").count
    assert_equal 2, Issue.tagged_with("a1").count
  end  

  private

  def add_issue project, tags, closed
    issue = Issue.generate!(:project_id => project.id)
    issue.tag_list = tags

    if closed
      issue.status = IssueStatus.find(:first, :conditions => {:is_closed => true})
    end

    issue.save
    issue
  end  

end
