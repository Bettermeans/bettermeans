class AddProjectidToTaggable < ActiveRecord::Migration
  def self.up
    add_column :taggings, :project_id, :integer
  end

  def self.down
    remove_column :taggings, :project_id
  end
end
