module RedmineTags
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval {}
      end

      module ClassMethods
      end

      module InstanceMethods
        # Returns link to the page with issues filtered by specified filters
        # === Parameters
        # * <i>title</i> = Link title text
        # * <i>filters</i> = Filters to be applied (see <tt>link_to_filter_options</tt> for details)
        # * <i>options</i> = (optional) Base options of the link
        # === Example
        # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]]
        # link_to_filter 'foobar', [[ :tags, '~', 'foobar' ]], :project_id => project
        def link_to_filter(title, filters, options = {})
          options.merge! link_to_filter_options(filters)
          link_to title, options
        end

        # Returns Hash suitable for passing it to the <tt>to_link</tt>
        # === Parameters
        # * <i>filters</i> = Array of arrays. Each child array is an array of strings:
        #                    name, operator and value
        # === Example
        # link_to 'foobar', link_to_filter_options [[ :tags, '~', 'foobar' ]]
        #
        # filters = [[ :tags, '~', 'bazbaz' ], [:status_id, 'o']]
        # link_to 'bazbaz', link_to_filter_options filters
        def link_to_filter_options(filters)
          options = {
            :controller => 'issues', :action => 'index', :set_filter => 1,
            :fields => [], :values => {}, :operators => {}
          }

          filters.each do |f|
            name, operator, value = f
            options[:fields].push name
            options[:operators][name] = operator
            options[:values][name] = [ value ]
          end

          options
        end
      end
    end
  end
end
