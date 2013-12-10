# This file is a part of redmine_tags
# Redmine plugin, that adds tagging support.
#
# Copyright (c) 2010 Aleksey V Zapparov AKA ixti
#
# redmine_tags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_tags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class RedmineTags::Patches::IssueTest < ActiveSupport::TestCase
  fixtures :users, :projects, :issue_statuses, :enumerations, :trackers

  def setup
    # run as the admin
    User.stubs(:current).returns(users(:users_001))

    @project_a = Project.generate!
    @project_b = Project.generate!

    add_issue @project_a, %w{a1 a2}, false
    add_issue @project_a, %w{a2 a3}, false
    add_issue @project_a, %w{a4 a5}, true
    add_issue @project_b, %w{b6 b7}, true
    add_issue @project_b, %w{b8 b9}, false
  end

  def add_issue project, tags, closed
    issue = Issue.generate!(:project_id => project.id)
    issue.tag_list = tags

    if closed
      issue.status = IssueStatus.find(:first, :conditions => {:is_closed => true})
    end

    issue.save!
  end

  test "patch was applied" do
    assert_respond_to Issue, :available_tags, 'Issue has available_tags getter'
    assert_respond_to Issue.new, :tags, 'Issue instance has tags getter'
    assert_respond_to Issue.new, :tags=, 'Issue instance has tags setter'
    assert_respond_to Issue.new, :tag_list=, 'Issue instance has tag_list setter'
  end

  test "available tags should return list of distinct tags" do
    assert_equal 9, Issue.available_tags.count
  end

  test "available tags should allow list tags of open issues only" do
    assert_equal 5, Issue.available_tags(:open_only => true).count
  end

  test "available tags should allow list tags of specific project only" do
    assert_equal 5, Issue.available_tags(:project => @project_a).count
    assert_equal 4, Issue.available_tags(:project => @project_b).count

    assert_equal 3, Issue.available_tags(:open_only => true, :project => @project_a).count
    assert_equal 2, Issue.available_tags(:open_only => true, :project => @project_b).count
  end

  test "available tags should allow list tags found by name" do
    assert_equal 5, Issue.available_tags(:name_like => 'a').count
    assert_equal 4, Issue.available_tags(:name_like => 'b').count
    assert_equal 1, Issue.available_tags(:name_like => 'a1').count
    assert_equal 1, Issue.available_tags(:name_like => 'a2').count

    assert_equal 5, Issue.available_tags(:name_like => 'a', :project => @project_a).count
    assert_equal 0, Issue.available_tags(:name_like => 'b', :project => @project_a).count
    assert_equal 3, Issue.available_tags(:name_like => 'a', :open_only => true, :project => @project_a).count
    assert_equal 0, Issue.available_tags(:name_like => 'b', :open_only => true, :project => @project_a).count
  end
end
