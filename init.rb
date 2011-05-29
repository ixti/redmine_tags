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

config.gem "acts-as-taggable-on", :version => '2.0.6'

require 'redmine'

Redmine::Plugin.register :redmine_tags do
  name        'redmine_tags'
  author      'Aleksey V Zapparov AKA "ixti"'
  description 'redMine tagging support'
  version     '1.1.4'
  url         'http://www.ixti.ru/'
  author_url  'http://www.ixti.ru/'

  requires_redmine :version_or_higher => '1.0.0'

  settings :default => {
    :issues_sidebar => 'none',
    :issues_show_count => 0,
    :issues_open_only => 0
  }, :partial => 'tags/settings'
end


require 'dispatcher'

Dispatcher.to_prepare :redmine_tags do
  unless Issue.included_modules.include?(RedmineTags::Patches::IssuePatch)
    Issue.send(:include, RedmineTags::Patches::IssuePatch)
  end

  unless IssuesHelper.included_modules.include?(RedmineTags::Patches::IssuesHelperPatch)
    IssuesHelper.send(:include, RedmineTags::Patches::IssuesHelperPatch)
  end

  unless AutoCompletesController.included_modules.include?(RedmineTags::Patches::AutoCompletesControllerPatch)
    AutoCompletesController.send(:include, RedmineTags::Patches::AutoCompletesControllerPatch)
  end

  unless Query.included_modules.include?(RedmineTags::Patches::QueryPatch)
    Query.send(:include, RedmineTags::Patches::QueryPatch)
  end

  unless QueriesHelper.included_modules.include?(RedmineTags::Patches::QueriesHelperPatch)
    QueriesHelper.send(:include, RedmineTags::Patches::QueriesHelperPatch)
  end
end


require 'redmine_tags/hooks/model_issue_hook'
require 'redmine_tags/hooks/views_issues_hook'
