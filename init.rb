# This file is a part of redmine_tags
# redMine plugin, that adds tagging support.
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

require 'redmine'
require 'redmine_tags'


Redmine::Plugin.register :redmine_tags do
  name        'redmine_tags'
  author      'Aleksey V Zapparov AKA "ixti"'
  description 'redMine tagging support'
  version     '2.0.1-dev'
  url         'https://github.com/ixti/redmine_tags/'
  author_url  'http://www.ixti.net/'

  requires_redmine :version_or_higher => '1.2.0'

  settings :default => {
    :issues_sidebar => 'none',
    :issues_show_count => 0,
    :issues_open_only => 0,
    :issues_sort_by => 'name',
    :issues_sort_order => 'asc'
  }, :partial => 'tags/settings'
end


ActionDispatch::Callbacks.to_prepare do
  unless Issue.included_modules.include?(RedmineTags::Patches::IssuePatch)
    Issue.send(:include, RedmineTags::Patches::IssuePatch)
  end

  unless WikiPage.included_modules.include?(RedmineTags::Patches::WikiPagePatch)
    WikiPage.send(:include, RedmineTags::Patches::WikiPagePatch)
  end

  unless IssuesHelper.included_modules.include?(RedmineTags::Patches::IssuesHelperPatch)
    IssuesHelper.send(:include, RedmineTags::Patches::IssuesHelperPatch)
  end

  unless WikiHelper.included_modules.include?(RedmineTags::Patches::WikiHelperPatch)
    WikiHelper.send(:include, RedmineTags::Patches::WikiHelperPatch)
  end

  unless AutoCompletesController.included_modules.include?(RedmineTags::Patches::AutoCompletesControllerPatch)
    AutoCompletesController.send(:include, RedmineTags::Patches::AutoCompletesControllerPatch)
  end

  base = ActiveSupport::Dependencies::search_for_file('issue_query') ? IssueQuery : Query
  unless base.included_modules.include?(RedmineTags::Patches::QueryPatch)
    base.send(:include, RedmineTags::Patches::QueryPatch)
  end

  base = ActiveSupport::Dependencies::search_for_file('issue_queries_helper') ? IssueQueriesHelper : QueriesHelper
  unless base.included_modules.include?(RedmineTags::Patches::QueriesHelperPatch)
    base.send(:include, RedmineTags::Patches::QueriesHelperPatch)
  end
end


require 'redmine_tags/hooks/model_issue_hook'
require 'redmine_tags/hooks/views_issues_hook'
require 'redmine_tags/hooks/views_wiki_hook'
