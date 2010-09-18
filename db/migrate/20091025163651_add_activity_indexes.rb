class AddActivityIndexes < ActiveRecord::Migration
  def self.up
    add_index :journals, :created_at
    add_index :changesets, :committed_on
    add_index :wiki_content_versions, :updated_at
    add_index :messages, :created_at
    add_index :issues, :created_at
    add_index :news, :created_at
    add_index :attachments, :created_at
    add_index :documents, :created_at
    add_index :time_entries, :created_at
  end

  def self.down
    remove_index :journals, :created_at
    remove_index :changesets, :committed_on
    remove_index :wiki_content_versions, :updated_at
    remove_index :messages, :created_at
    remove_index :issues, :created_at
    remove_index :news, :created_at
    remove_index :attachments, :created_at
    remove_index :documents, :created_at
    remove_index :time_entries, :created_at
  end
end
