module RedmineTags
  module Patches
    module WikiPagePatch
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          acts_as_taggable

          searchable_options[:columns] << "tags.name"
          searchable_options[:preload] << :tags
          old_scope = searchable_options[:scope]
          searchable_options[:scope] = lambda do |options|
            new_scope = old_scope.is_a?(Proc) ? old_scope.call(options) : old_scope
            new_scope
              .joins("LEFT JOIN taggings ON taggings.taggable_id = wiki_pages.id AND taggings.context = 'tags' AND taggings.taggable_type = 'WikiPage'")
              .joins('LEFT JOIN tags ON tags.id = taggings.tag_id')
          end

          scope :on_project, ->(project) {
              project = project.id if project.is_a? Project
              where "#{ Project.table_name }.id = ?", project
            }
          WikiPage.safe_attributes 'tag_list'
        end
      end

      module ClassMethods
        # Returns available issue tags
        # === Parameters
        # * <i>options</i> = (optional) Options hash of
        #   * project   - Project to search in.
        #   * name_like - String. Substring to filter found tags.
        def available_tags(options = {})
          ids_scope = WikiPage.select("#{WikiPage.table_name}.id").joins(:wiki => :project)
          ids_scope = ids_scope.on_project(options[:project]) if options[:project]
          conditions = ['']

          sql_query = ids_scope.to_sql

          conditions[0] << <<-SQL
            tag_id IN (
              SELECT taggings.tag_id
                FROM taggings
               WHERE taggings.taggable_id IN (#{sql_query}) AND taggings.taggable_type = 'WikiPage'
            )
          SQL

          # limit to the tags matching given %name_like%
          if options[:name_like]
            conditions[0] << case self.connection.adapter_name
                               when 'PostgreSQL'
                                 "AND tags.name ILIKE ?"
                               else
                                 "AND tags.name LIKE ?"
                             end
            conditions << "%#{options[:name_like].downcase}%"
          end
          self.all_tag_counts(:conditions => conditions, :order => "tags.name ASC")
        end
      end
    end
  end
end

base = WikiPage
patch = RedmineTags::Patches::WikiPagePatch
base.send(:include, patch) unless base.included_modules.include?(patch)
