module RedmineTags
  module Patches
    module ReportsHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :aggregate_path_without_redmine_tags, :aggregate_path
          alias_method :aggregate_path, :aggregate_path_with_redmine_tags
        end
      end

      module InstanceMethods
        def aggregate_path_with_redmine_tags(project, field, row, options={})
          if field == 'tag_id'
            tag = row
            default_operators = Query.operators.map {|k, v| k}
            filters = []
            options.each do |k, v|
              if default_operators.include? v
                filters << [k, v]
              else
                filters << [k, '=', v]
              end
            end
            filters << [:tags, '=', tag.name]
            options = link_to_filter_options(filters)
          end
          aggregate_path_without_redmine_tags(project, field, row, options)
        end

      end
    end
  end
end

base = ReportsHelper
patch = RedmineTags::Patches::ReportsHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
