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

require_dependency 'issue'

module RedmineTags
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.class_eval do
          unloadable
          acts_as_taggable

          named_scope :on_project, lambda { |project|
            project = project.id if project.is_a? Project
            { :conditions => ["#{Project.table_name}.id=?", project] }
          }
        end
      end

      module ClassMethods
        TAGGING_IDS_LIMIT_SQL = <<-SQL
          tag_id IN (
            SELECT #{ActsAsTaggableOn::Tagging.table_name}.tag_id
              FROM #{ActsAsTaggableOn::Tagging.table_name}
             WHERE #{ActsAsTaggableOn::Tagging.table_name}.taggable_id IN (?)
          )
        SQL

        # Returns available issue tags
        # === Parameters
        # * <i>options</i> = (optional) Options hash of
        #   * project   - Project to search in.
        #   * open_only - Boolean. Whenever search within open issues only.
        #   * name_like - String. Substring to filter found tags.
        def available_tags(options = {})
          ids_scope = Issue.visible
          ids_scope = ids_scope.on_project(options[:project]) if options[:project]
          ids_scope = ids_scope.open if options[:open_only]

          visible = ARCondition.new

          # limit to the tags matching given %name_like%
          visible << ["#{ActsAsTaggableOn::Tag.table_name}.name LIKE ?",
                      "%#{options[:name_like].downcase}%"] if options[:name_like]

          visible << [TAGGING_IDS_LIMIT_SQL,
                      ids_scope.map{ |issue| issue.id }.push(-1)]

          self.all_tag_counts(:conditions => visible.conditions)
        end
      end
    end
  end
end
