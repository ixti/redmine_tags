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

# This module patches a controller so that the methods from TagsHelper and
# IssuesTagsHelper are available in its views.
module RedmineTags
  module Patches
    module AddHelpersForIssueTagsPatch
      def self.apply(controller)
        controller.send(:helper, 'tags')
        controller.send(:helper, 'issues_tags')
      end
    end
  end
end
