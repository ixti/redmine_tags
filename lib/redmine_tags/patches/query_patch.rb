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

          base.operators_by_filter_type.merge!({
            :list_tags => [ "=", "!", "~", "!~" ]
          })
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
                #{tags_alias}.name = ?
            END

            joins << sanitize_sql([join, tag])
          end
          
          joins.join(" ")
        end
      end


      module InstanceMethods
        def statement_extended
          tags_filter     = filters.delete 'tags'
          sql_statements  = statement_original

          if tags_filter
            filters.merge!( 'tags' => tags_filter )

            operator  = operator_for('tags')
            values    = values_for('tags').clone
            tags      = ActsAsTaggableOn::Tag.table_name
            taggings  = ActsAsTaggableOn::Tagging.table_name

            ids = <<-SQL
              SELECT DISTINCT #{taggings}.taggable_id 
                FROM #{taggings}
               INNER JOIN #{tags} ON #{tags}.id = #{taggings}.tag_id #{Query.joins_for_match_all_tags(values)}
               WHERE #{taggings}.taggable_type = 'Issue'
            SQL

            # TODO: uncomment, once :list_tags will be successfully added?
            #if "=" == operator or "!" == operator
            #  taggings_alias  = taggings + "_recursive"
            #  strict_subquery = <<-SQL
            #    SELECT COUNT(#{taggings_alias}.taggable_id) 
            #      FROM #{taggings} #{taggings_alias}
            #    WHERE #{taggings_alias}.taggable_id = #{taggings}.taggable_id
            #  SQL
            #  ids << " AND #{values.length} = (#{strict_subquery})"
            #end

            compare = operator.start_with?("!") ? "NOT IN" : "IN"
            sql_statements << " AND ( #{Issue.table_name}.id #{compare} ( #{ids} ) )"
          end

          sql_statements
        end


        def available_filters_extended
          unless @available_filters 
            available_filters_original.merge!({ 'tags' => {
              # TODO: should be :list_tags instead, but it makes list of values empty
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

