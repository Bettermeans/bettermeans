class DropVersion < ActiveRecord::Migration
  def self.up
    drop_table :versions
    remove_column :issues, :fixed_version_id
  end

  def self.down
  end
end
