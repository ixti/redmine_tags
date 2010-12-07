module RedmineTags
  module Hooks
    class ModelIssueHook < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context={})
        save_tags_to_issue(context, true)
      end

      # Issue has an after_save method that calls reload (update_nested_set_attributes)
      # This makes it impossible for a new record to get a tag_list, it's
      # cleared on reload. So instead, hook in after the Issue#save to update
      # this issue's tag_list and call #save ourselves.
      def controller_issues_new_after_save(context={})
      #  save_tags_to_issue(context, false)
      #  context[:issue].save
      end

      def save_tags_to_issue(context, create_journal)
        params = context[:params]

        if params && params[:issue] && params[:issue][:tag_list].present?
          old_tag_list = context[:issue].tag_list
          new_tag_list = params[:issue][:tag_list]
          
          context[:issue].tag_list = new_tag_list

          if create_journal
            context[:issue].current_journal.details << JournalDetail.new(:property => 'attr',
                                                                         :prop_key => 'tag_list',
                                                                         :old_value => old_tag_list.to_s,
                                                                         :value => new_tag_list.to_s) unless old_tag_list == new_tag_list || context[:issue].current_journal.blank?
          end
          
        end
      end
    end
  end
end
