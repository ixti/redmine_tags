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

          searchable_options[:columns] << "#{ActsAsTaggableOn::Tag.table_name}.name"
          searchable_options[:include] << :tags

          scope :on_project, lambda { |project|
            project = project.id if project.is_a? Project
            { :conditions => ["#{Project.table_name}.id=?", project] }
          }

#          with this changes do not saved in journal
#          Issue.safe_attributes 'tag_list'
        end
      end

      module ClassMethods

        # Returns available issue tags
        # === Parameters
        # * <i>options</i> = (optional) Options hash of
        #   * project   - Project to search in.
        #   * open_only - Boolean. Whenever search within open issues only.
        #   * name_like - String. Substring to filter found tags.
        def available_tags(options = {})
          ids_scope = Issue.visible.select("#{Issue.table_name}.id").joins(:project)
          ids_scope = ids_scope.on_project(options[:project]) if options[:project]
          ids_scope = ids_scope.open.joins(:status) if options[:open_only]

          conditions = [""]

          sql_query = ids_scope.to_sql

          conditions[0] << <<-SQL
            tag_id IN (
              SELECT #{ActsAsTaggableOn::Tagging.table_name}.tag_id
                FROM #{ActsAsTaggableOn::Tagging.table_name}
               WHERE #{ActsAsTaggableOn::Tagging.table_name}.taggable_id IN (#{sql_query}) AND #{ActsAsTaggableOn::Tagging.table_name}.taggable_type = 'Issue'
            )
          SQL

          # limit to the tags matching given %name_like%
          if options[:name_like]
            conditions[0] << "AND #{ActsAsTaggableOn::Tag.table_name}.name LIKE ?"
            conditions << "%#{options[:name_like].downcase}%"
          end

          self.all_tag_counts(:conditions => conditions)
        end
      end
    end
  end
end
