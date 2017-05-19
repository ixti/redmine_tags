module RedmineTags
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          unloadable

          alias_method_chain :available_filters, :tags
          alias_method_chain :available_columns, :tags
        end
      end

      module InstanceMethods
        def sql_for_tags_field(field, operator, value)
          case operator
            when '=', '!'
              issues = Issue.tagged_with(values_for('tags'), any: true)
            when '!*'
              issues = Issue.tagged_with ActsAsTaggableOn::Tag.all.map(&:to_s), exclude: true
            else
              issues = Issue.tagged_with ActsAsTaggableOn::Tag.all.map(&:to_s), any: true
            end
            compare = operator.eql?('!') ? 'NOT IN' : 'IN'
            ids_list = issues.collect {|issue| issue.id }.push(0).join(',')

            "( #{ Issue.table_name }.id #{ compare } (#{ ids_list }) )"
        end

        def available_filters_with_tags
          if @available_filters.blank?
            add_available_filter('tags', :type => :list_optional, :name => l(:field_tags),
              :values => Issue.available_tags(project: project).collect {|t| [t.name, t.name]}
            ) if !available_filters_without_tags.key?('tags')
          else
            available_filters_without_tags
          end
          @available_filters
        end

        def available_columns_with_tags
          if @available_columns.blank?
            @available_columns = available_columns_without_tags
            @available_columns << QueryColumn.new(:tags)
          else
            @available_columns_without_tags
          end
          @available_columns
        end
      end
    end
  end
end

base = IssueQuery
patch = RedmineTags::Patches::IssueQueryPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
