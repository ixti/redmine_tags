class RemoveWrongTagListJournals < ActiveRecord::Migration[4.2]
  def change
    # First, remove from journal details the tag changes where the new value is the same with the old_value
    JournalDetail.where("prop_key = 'tag_list' AND old_value = value").destroy_all

    # Remove all journals that do not have notes and neither attributes changes in the journal_details table
    Journal.joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id")
      .where("(#{Journal.table_name}.notes IS NULL OR #{Journal.table_name}.notes = '') AND #{Journal.table_name}.journalized_type = 'Issue'")
      .where("#{JournalDetail.table_name}.journal_id IS NULL")
      .destroy_all
  end
end
