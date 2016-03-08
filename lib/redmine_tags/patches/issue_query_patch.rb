module RedmineTags
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :statement_original, :statement
          alias_method :statement, :statement_extended
          alias_method :available_filters_original, :available_filters
          alias_method :available_filters, :available_filters_extended
          base.add_available_column QueryColumn.new(:tags)
        end
      end

      module InstanceMethods
        def statement_extended
          if filters
            filter  = filters.delete 'tags'
          end
          clauses = statement_original || ''
          if filter
            filters.merge! 'tags' => filter
            op = operator_for 'tags'
            case op
            when '=', '!'
              issues = Issue.tagged_with(values_for('tags'), any: true)
            when '!*'
              issues = Issue.tagged_with ActsAsTaggableOn::Tag.all.map(&:to_s), exclude: true
            else
              issues = Issue.tagged_with ActsAsTaggableOn::Tag.all.map(&:to_s), any: true
            end
            compare = op.eql?('!') ? 'NOT IN' : 'IN'
            ids_list = issues.collect {|issue| issue.id }.push(0).join(',')
            clauses << " AND " unless clauses.empty?
            clauses << "( #{ Issue.table_name }.id #{ compare } (#{ ids_list }) ) "
          end
          clauses
        end

        def available_filters_extended
          unless @available_filters
            available_filters_original.merge!({ 'tags' => { name: l(:tags),
              type: :list_optional, order: 6,
              values: Issue.available_tags(project: project).collect {|t| [t.name, t.name] }
            }})
          end
          @available_filters
        end
      end
    end
  end
end

base = IssueQuery
patch = RedmineTags::Patches::IssueQueryPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
