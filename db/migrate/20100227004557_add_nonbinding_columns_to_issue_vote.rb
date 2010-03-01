class AddNonbindingColumnsToIssueVote < ActiveRecord::Migration
  def self.up
    add_column :issues, :accept_nonbind, :integer, :default => 0
    add_column :issues, :reject_nonbind, :integer, :default => 0
    add_column :issues, :accept_total_nonbind, :integer, :default => 0
    add_column :issues, :agree_nonbind, :integer, :default => 0
    add_column :issues, :disagree_nonbind, :integer, :default => 0
    add_column :issues, :agree_total_nonbind, :integer, :default => 0
    add_column :issues, :points_nonbind, :integer, :default => 0
    add_column :issues, :pri_nonbind, :integer, :default => 0
  end

  def self.down
    remove_column :issues, :accept_nonbind
    remove_column :issues, :reject_nonbind
    remove_column :issues, :accept_total_nonbind
    remove_column :issues, :agree_nonbind
    remove_column :issues, :disagree_nonbind
    remove_column :issues, :agree_total_nonbind
    remove_column :issues, :points_nonbind, :integer
    remove_column :issues, :pri_nonbind, :integer
  end
end
