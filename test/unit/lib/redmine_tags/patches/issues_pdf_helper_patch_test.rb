# frozen_string_literal: true

require File.expand_path('../../../../../test_helper', __FILE__)
require File.expand_path('test/unit/lib/redmine/export/pdf/issues_pdf_test', Rails.root)

class IssuesPdfHelperPatchTest < IssuesPdfHelperTest

  RedmineTags::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_tags).directory + '/test/fixtures/', [:taggings, :tags])

  # The reimplemented helper logic is verified using the inherited test cases.
  # Tests for added helper logic follow.

  def test_fetch_row_values_should_render_tag_list
    query = IssueQuery.new(:project => Project.find(1), :name => '_')
    query.column_names = [:subject, :tags]
    issue = Issue.find(3)

    results = fetch_row_values(issue, query, 0)
    assert_equal ['3', 'Error 281 when updating a recipe', 'Security,Production'], results
  end
end
