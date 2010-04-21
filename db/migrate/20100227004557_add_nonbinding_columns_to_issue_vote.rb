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
    
    Issue.update_all(:accept_nonbind => 0,:reject_nonbind => 0, :accept_total_nonbind => 0, :agree_nonbind => 0, :disagree_nonbind => 0, :agree_total_nonbind => 0, :points_nonbind => 0, :pri_nonbind => 0)
    
  end

  def self.down
    remove_column :issues, :accept_nonbind
    remove_column :issues, :reject_nonbind
    remove_column :issues, :accept_total_nonbind
    remove_column :issues, :agree_nonbind
    remove_column :issues, :disagree_nonbind
    remove_column :issues, :agree_total_nonbind
    remove_column :issues, :points_nonbind
    remove_column :issues, :pri_nonbind
  end
end
