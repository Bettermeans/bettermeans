class RemovePriorityidFromIssues < ActiveRecord::Migration
  def self.up
    remove_column :issues, :priority_id
  end

  def self.down
  end
end
