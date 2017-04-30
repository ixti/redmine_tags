module RedmineTags
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          acts_as_ordered_taggable

          safe_attributes 'tag_list'
          alias_method_chain :copy_from, :redmine_tags

          searchable_options[:columns] << "tags.name"
          searchable_options[:preload] << :tags
          old_scope = searchable_options[:scope]
          searchable_options[:scope] = lambda do |options|
            new_scope = old_scope.is_a?(Proc) ? old_scope.call(options) : old_scope
            new_scope
              .joins("LEFT JOIN taggings ON taggings.taggable_id = issues.id AND taggings.context = 'tags' AND taggings.taggable_type = 'Issue'")
              .joins('LEFT JOIN tags ON tags.id = taggings.tag_id')
          end

          # TODO: should we have this on or not?
          # with this changes do not saved in journal
          # Issue.safe_attributes 'tag_list'

          # TODO: Not sure which one of these to keep yet
          # scope :on_project, ->(project) {
          #     project = project.id if project.is_a? Project
          #     where "#{ Project.table_name }.id = ?", project
          #   }

          scope :on_project, lambda { |project|
            project = Project.find(project) unless project.is_a? Project
            where("#{project.project_condition(Setting.display_subprojects_issues?)}")
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
          issues_scope = Issue.visible.select('issues.id').joins(:project)
          issues_scope = issues_scope.on_project(options[:project]) if options[:project]
          issues_scope = issues_scope.joins(:status).open if options[:open_only]

          result_scope = ActsAsTaggableOn::Tag
            .joins(:taggings)
            .select('tags.id, tags.name, tags.taggings_count, COUNT(taggings.id) as count')
            .group('tags.id, tags.name, tags.taggings_count')
            .where(taggings: { taggable_type: 'Issue', taggable_id: issues_scope})

          if options[:name_like]
            pattern = "%#{options[:name_like].to_s.strip}%"
            result_scope = result_scope.where('LOWER(tags.name) LIKE LOWER(:p)', :p => pattern)
          end

          result_scope
        end

        def remove_unused_tags!
          unused = ActsAsTaggableOn::Tag.find_by_sql(<<-SQL)
            SELECT * FROM tags WHERE id NOT IN (
              SELECT DISTINCT tag_id FROM taggings
            )
          SQL
          unused.each(&:destroy)
        end

        def get_common_tag_list_from_multiple_issues(ids)
          common_tags = ActsAsTaggableOn::Tag.joins(:taggings)
            .select('tags.id', 'tags.name')
            .where(:taggings => {:taggable_type => 'Issue', :taggable_id => ids})
            .group('tags.id')
            .having("count(*) = #{ids.count}").to_a

          ActsAsTaggableOn::TagList.new(common_tags)
        end
      end

      module InstanceMethods
        def copy_from_with_redmine_tags(arg, options = {})
          copy_from_without_redmine_tags(arg, options)
          issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
          self.tag_list = issue.tag_list
          self
        end
      end
    end
  end
end

base = Issue
patch = RedmineTags::Patches::IssuePatch
base.send(:include, patch) unless base.included_modules.include?(patch)
