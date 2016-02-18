class ActsAsTaggableMigration < ActiveRecord::Migration
  def up
    # ActsAsTaggableOnMigration
    unless table_exists?(:tags)
      create_table :tags do |t|
        t.string :name
      end

      create_table :taggings do |t|
        t.references :tag
        t.references :taggable, polymorphic: true
        t.references :tagger, polymorphic: true
        # Limit is created to prevent MySQL error on index
        # length for MyISAM table type: http://bit.ly/vgW2Ql
        t.string :context, limit: 128
        t.datetime :created_at
      end

      add_index :taggings, :tag_id
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end

    # redmine_crm skips some collumns when creating the taggings table
    unless column_exists?(:taggings, :context)
      add_column :taggings, :context, :string, limit: 128
    end

    unless column_exists?(:taggings, :tagger_id)
      change_table :taggings do |t|
        t.references :tagger, polymorphic: true
      end
    end

    # AddMissingUniqueIndices
    unless column_exists?(:tags, :taggings_count)
      # redmine_crm skips the following indexes so we have to check their exitance
      unless index_exists?(:tags, :name)
        add_index :tags, :name, unique: true
      end

      if index_exists?(:taggings, :tag_id)
        remove_index :taggings, :tag_id
      end

      if index_exists?(:taggings, [:taggable_id, :taggable_type, :context])
        remove_index :taggings, [:taggable_id, :taggable_type, :context]
      end

      add_index(
        :taggings,
        [
          :tag_id,
          :taggable_id,
          :taggable_type,
          :context,
          :tagger_id,
          :tagger_type
        ],
        unique: true, name: 'taggings_idx'
      )

      # AddTaggingsCounterCacheToTags
      add_column :tags, :taggings_count, :integer, default: 0
      ActsAsTaggableOn::Tag.reset_column_information
      ActsAsTaggableOn::Tag.find_each do |tag|
        ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
      end

      # AddMissingTaggableIndex
      add_index :taggings, [:taggable_id, :taggable_type, :context]

      # ChangeCollationForTagNames
      if ActsAsTaggableOn::Utils.using_mysql?
        execute(
          'ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;'
        )
      end
    end

    # AddMissingIndexes
    unless index_exists?(:taggings, :tag_id)
      add_index :taggings, :tag_id
      add_index :taggings, :taggable_id
      add_index :taggings, :taggable_type
      add_index :taggings, :tagger_id
      add_index :taggings, :context
      add_index :taggings, [:tagger_id, :tagger_type]
      add_index(
        :taggings,
        [:taggable_id, :taggable_type, :tagger_id, :context],
        name: 'taggings_idy'
      )
    end
  end

  def down
    if ENV['FORCE_REDMINE_TAGS_TABLES_REMOVAL'] == 'yes'
      drop_table :taggings
      drop_table :tags
    else
      puts '********' * 10
      puts 'WARNING: This will remove the `tags` and `taggings` tabels which ' \
        'may be used by other plugins.'
      puts 'If you are sure you want to remove them, run the command again ' \
        'supplying the `FORCE_REDMINE_TAGS_TABLES_REMOVAL=yes` variable.'
      puts '********' * 10
      raise ActiveRecord::IrreversibleMigration
    end
  end
end
