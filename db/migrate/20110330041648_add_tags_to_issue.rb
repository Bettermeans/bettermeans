class AddTagsToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :tags_copy, :string
  end

  def self.down
    remove_column :issues, :tags_copy
  end
end
