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
      end


      module InstanceMethods
        def statement_extended
          filter  = filters.delete 'tags'
          clauses = statement_original

          if filter
            filters.merge!( 'tags' => filter )

            values    = values_for('tags').clone
            compare   = operator_for('tags').eql?('=') ? 'IN' : 'NOT IN'

            #TODO: Replace with pure SQL restriction
            ids_list  = Issue.tagged_with(values).collect{ |issue| issue.id }.push(-1).join(',')

            clauses << " AND ( #{Issue.table_name}.id #{compare} (#{ids_list}) ) "
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

