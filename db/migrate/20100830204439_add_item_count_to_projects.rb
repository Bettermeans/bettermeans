class AddItemCountToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :issue_count, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :item_count
  end
end
