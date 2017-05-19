module RedmineTags
  module Hooks
    class ModelIssueHook < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context = {})
        save_tags_to_issue context, true
      end

      def controller_issues_bulk_edit_before_save(context = {})
        bulk_update_tags_to_issues context, true
      end

      # Issue has an after_save method that calls reload (update_nested_set_attributes)
      # This makes it impossible for a new record to get a tag_list, it's
      # cleared on reload. So instead, hook in after the Issue#save to update
      # this issue's tag_list and call #save ourselves.
      def controller_issues_new_after_save(context = {})
        save_tags_to_issue context, false
        context[:issue].save
      end

      def save_tags_to_issue(context, create_journal)
        params = context[:params]
        issue = context[:issue]
        if params && params[:issue] && !params[:issue][:tag_list].nil?
          old_tags = issue.tag_list.to_s
          issue.tag_list = params[:issue][:tag_list]
          new_tags = issue.tag_list.to_s
          # without this when reload called in Issue#save all changes will be
          # gone :(
          issue.save_tags
          create_journal_entry(issue, old_tags, new_tags) if create_journal

          Issue.remove_unused_tags!
        end
      end

      def bulk_update_tags_to_issues(context, create_journal)
        params = context[:params]
        issue = context[:issue]
        common_tags = []

        common_tags = params[:common_tags].split(ActsAsTaggableOn.delimiter).collect(&:strip) if params[:common_tags].present?
        tag_list = params[:issue][:new_tag_list].split(ActsAsTaggableOn.delimiter) if params[:issue] && !params[:issue][:new_tag_list].nil?

        if common_tags && tag_list
          current_tags = issue.tag_list

          # calculate tags to be added or removed
          tags_to_add = tag_list - common_tags
          tags_to_remove = common_tags - tag_list

          # variables for journal entry
          old_tags = current_tags.to_s
          new_tags = current_tags.add(tags_to_add).remove(tags_to_remove)

          issue.tag_list = new_tags
          # without this when reload called in Issue#save all changes will be
          # gone :(
          issue.save_tags
          create_journal_entry(issue, old_tags, new_tags) if create_journal

          Issue.remove_unused_tags!
        end
      end

      def create_journal_entry(issue, old_tags, new_tags)
        if !(old_tags == new_tags || issue.current_journal.blank?)
          issue.current_journal.details << JournalDetail.new(
            property: 'attr', prop_key: 'tag_list', old_value: old_tags.to_s,
            value: new_tags.to_s)
        end
      end
    end
  end
end
