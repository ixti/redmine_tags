# This file is a part of redmine_tags
# redMine plugin, that adds tagging support.
#
# Copyright (c) 2010 Eric Davis
# Copyright (c) 2010 Aleksey V Zapparov AKA ixti
#
# redmine_tags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_tags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.

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
        save_tags_to_issue(context, false)
        context[:issue].save
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
