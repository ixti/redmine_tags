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
        base.extend ClassMethods
        base.class_eval do
          unloadable
          acts_as_taggable

          searchable_options[:columns] << "#{ ActsAsTaggableOn::Tag.table_name }.name"
          searchable_options[:preload] << :tags

          scope :on_project, -> (project) {
              project = project.id if project.is_a? Project
              where "#{ Project.table_name }.id = ?", project
            }
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
          ids_scope = Issue.visible.select("#{ Issue.table_name }.id").joins(:project)
          ids_scope = ids_scope.on_project(options[:project]) if options[:project]
          ids_scope = ids_scope.open.joins(:status) if options[:open_only]
          conditions = ['']
          sql_query = ids_scope.to_sql
          conditions[0] << <<-SQL
            tag_id IN (
              SELECT #{ ActsAsTaggableOn::Tagging.table_name }.tag_id
                FROM #{ ActsAsTaggableOn::Tagging.table_name }
              WHERE #{ ActsAsTaggableOn::Tagging.table_name }.taggable_id IN (
                  #{ sql_query }
                )
                AND #{ ActsAsTaggableOn::Tagging.table_name }.taggable_type = 'Issue'
            )
          SQL
          # limit to the tags matching given %name_like%
          if options[:name_like]
            conditions[0] << "AND #{ ActsAsTaggableOn::Tag.table_name }.name LIKE ?"
            conditions << "%#{ options[:name_like].downcase }%"
          end
          self.specific_tag_counts(conditions: conditions, taggable_id_sql: sql_query)
        end

        ##
        # Calculate the tag counts for all tags.
        #
        # @param [Hash] options Options:
        #   * :start_at   - Restrict the tags to those created after a certain time
        #   * :end_at     - Restrict the tags to those created before a certain time
        #   * :conditions - A piece of SQL conditions to add to the query
        #   * :limit      - The maximum number of tags to return
        #   * :order      - A piece of SQL to order by. Eg 'tags.count desc' or 'taggings.created_at desc'
        #   * :at_least   - Exclude tags with a frequency less than the given value
        #   * :at_most    - Exclude tags with a frequency greater than the given value
        #   * :on         - Scope the find to only include a certain context
        def specific_tag_counts(options = {})
          options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit, :on, :id, :taggable_id_sql
          scope = {}
          tagging_table = ActsAsTaggableOn::Tagging.table_name
          tag_table = ActsAsTaggableOn::Tag.table_name
          ## Generate conditions:
          options[:conditions] = sanitize_sql(options[:conditions]) if options[:conditions]
          start_at_conditions = sanitize_sql(["#{ tagging_table }.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
          end_at_conditions = sanitize_sql(["#{ tagging_table }.created_at <= ?", options.delete(:end_at)])   if options[:end_at]
          taggable_conditions = sanitize_sql(["#{ tagging_table }.taggable_type = ?", base_class.name])
          taggable_conditions << sanitize_sql([" AND #{ tagging_table }.taggable_id = ?", options.delete(:id)])  if options[:id]
          taggable_conditions << sanitize_sql([" AND #{ tagging_table }.context = ?", options.delete(:on).to_s]) if options[:on]
          tagging_conditions = [taggable_conditions, scope[:conditions],
            start_at_conditions, end_at_conditions].compact.reverse
          tag_conditions = [options[:conditions]].compact.reverse
          # Generate joins:
          taggable_join = "INNER JOIN #{ table_name } ON #{ table_name }.#{ primary_key } = #{ tagging_table }.taggable_id"
          # Current model is STI descendant, so add type checking to the join condition
          taggable_join << " AND #{ table_name }.#{ inheritance_column } = '#{ name }'" unless descends_from_active_record?
          tagging_joins = [taggable_join, scope[:joins]].compact
          tag_joins = [].compact
          # Generate scope:
          tagging_scope = ActsAsTaggableOn::Tagging.select("#{ tagging_table }.tag_id, COUNT(#{ tagging_table }.tag_id) AS tags_count")
          tag_scope = ActsAsTaggableOn::Tag.select("#{ tag_table }.*, #{ tagging_table }.tags_count AS count")
            .order(options[:order]).limit(options[:limit])
          # Joins and conditions
          tagging_joins.each {|join| tagging_scope = tagging_scope.joins join }
          tagging_conditions.each {|condition| tagging_scope = tagging_scope.where condition }
          tag_joins.each {|join| tag_scope = tag_scope.joins join }
          tag_conditions.each {|condition| tag_scope = tag_scope.where(condition) }
          # GROUP BY and HAVING clauses:
          at_least = sanitize_sql(["COUNT(#{ tagging_table }.tag_id) >= ?", options.delete(:at_least)]) if options[:at_least]
          at_most = sanitize_sql(["COUNT(#{ tagging_table }.tag_id) <= ?", options.delete(:at_most)]) if options[:at_most]
          having = ["COUNT(#{ tagging_table }.tag_id) > 0", at_least, at_most].compact.join(' AND ')
          group_columns = "#{ tagging_table }.tag_id"
          # Append the current scope to the scope, because we can't use scope(:find) in RoR 3.0 anymore:
          scoped_select = "#{ table_name }.#{ primary_key }"
          select_query = "#{ select(scoped_select).to_sql }"
          select_query = options[:taggable_id_sql] if options[:taggable_id_sql]
          res = ActiveRecord::Base.connection.select_all(select_query).map { |item| item.values }.flatten.compact.join(",")
          res = "NULL" if res.blank?
          tagging_scope = tagging_scope.where("#{ tagging_table }.taggable_id IN(#{ res })")
          tagging_scope = tagging_scope.group(group_columns).having(having)
          tag_scope = tag_scope.joins("JOIN (#{ tagging_scope.to_sql }) AS #{ tagging_table } ON #{ tagging_table }.tag_id = #{ tag_table }.id")
          tag_scope
        end
      end
    end
  end
end
