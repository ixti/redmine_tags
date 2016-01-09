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

module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :column_content_original, :column_content
          alias_method :column_content, :column_content_extended
        end
      end

      module InstanceMethods
        include TagsHelper

        def column_content_extended(column, issue)
          if column.name.eql? :tags
            column.value(issue).collect{ |t| render_tag_link(t) }
              .join(RedmineTags.settings[:issues_use_colors].to_i > 0 ? ' ' : ', ')
          else
            column_content_original column, issue
          end
        end
      end
    end
  end
end

base = QueriesHelper
patch = RedmineTags::Patches::QueriesHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
