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

require_dependency 'query'
if ActiveSupport::Dependencies::search_for_file('issue_query')
  require_dependency 'issue_query'
end

module RedmineTags
  module Patches
    module QueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method :statement_original, :statement
          alias_method :statement, :statement_extended

          alias_method :available_filters_original, :available_filters
          alias_method :available_filters, :available_filters_extended

          base.add_available_column(QueryColumn.new(:tags))
        end
      end


      module InstanceMethods
        def statement_extended
          filter  = filters.delete 'tags'
          clauses = statement_original || ""

          if filter
            filters.merge!( 'tags' => filter )

            op = operator_for('tags')
            case op
            when '=', '!'
              issues = Issue.tagged_with(values_for('tags').clone)
            when '!*'
              issues = Issue.tagged_with(ActsAsTaggableOn::Tag.all.map(&:to_s), :exclude => true)
            else
              issues = Issue.tagged_with(ActsAsTaggableOn::Tag.all.map(&:to_s), :any => true)
            end

            compare   = op.eql?('!') ? 'NOT IN' : 'IN'
            ids_list  = issues.collect{ |issue| issue.id }.push(0).join(',')

            clauses << " AND " unless clauses.empty?
            clauses << "( #{Issue.table_name}.id #{compare} (#{ids_list}) ) "
          end

          clauses
        end


        def available_filters_extended
          unless @available_filters 
            available_filters_original.merge!({ 'tags' => {
              :name   => l(:tags),
              :type   => :list_optional,
              :order  => 6,
              :values => Issue.available_tags(:project => project).collect{ |t| [t.name, t.name] }
            }})
          end
          @available_filters
        end
      end
    end
  end
end

