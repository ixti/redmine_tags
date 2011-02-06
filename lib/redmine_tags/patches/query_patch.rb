module RedmineTags
  module Patches
    module QueryPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method :statement_original, :statement
          alias_method :statement, :statement_extended

          alias_method :available_filters_original, :available_filters
          alias_method :available_filters, :available_filters_extended
        end
      end


      module ClassMethods
        # TODO: Should be extension of ActsAsTaggableOn
        def joins_for_match_all_tags(tags)
          joins = []
          
          tags.each_with_index do |tag, index|
            taggings_alias, tags_alias = "taggings_#{index}", "tags_#{index}"

            join = <<-END
              INNER JOIN #{ActsAsTaggableOn::Tagging.table_name} #{taggings_alias} ON
                #{taggings_alias}.taggable_id = #{Issue.table_name}.#{Issue.primary_key} AND
                #{taggings_alias}.taggable_type = #{quote_value(Issue.base_class.name)}

              INNER JOIN #{ActsAsTaggableOn::Tag.table_name} #{tags_alias} ON
                #{taggings_alias}.tag_id = #{tags_alias}.id AND
                #{tags_alias}.name = '%s'
            END

            joins << sanitize_sql_array([join, tag])
          end
          
          joins.join(" ")
        end
      end


      module InstanceMethods
        def statement_extended
          filter  = filters.delete 'tags'
          clauses = statement_original

          if filter
            filters.merge!( 'tags' => filter )

            tags      = ActsAsTaggableOn::Tag.table_name
            taggings  = ActsAsTaggableOn::Tagging.table_name
            values    = values_for('tags').clone
            compare   = operator_for('tags').eql?('=') ? 'IN' : 'NOT IN'
            ids_sql   = <<-SQL
              SELECT DISTINCT #{taggings}.taggable_id 
                FROM #{taggings}
               INNER JOIN #{tags} ON #{tags}.id = #{taggings}.tag_id #{Query.joins_for_match_all_tags(values)}
               WHERE #{taggings}.taggable_type = 'Issue'
            SQL

            clauses << " AND ( #{Issue.table_name}.id #{compare} ( #{ids_sql} ) )"
          end

          clauses
        end


        def available_filters_extended
          unless @available_filters 
            available_filters_original.merge!({ 'tags' => {
              :type   => :list,
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

