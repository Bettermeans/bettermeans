class AddIssueColumnsForIssueVote < ActiveRecord::Migration
  def self.up
    add_column :issues, :accept, :integer, :default => 0
    add_column :issues, :reject, :integer, :default => 0
    add_column :issues, :accept_total, :integer, :default => 0
    add_column :issues, :agree, :integer, :default => 0
    add_column :issues, :disagree, :integer, :default => 0
    add_column :issues, :agree_total, :integer, :default => 0
  end

  def self.down
    remove_column :issues, :accept
    remove_column :issues, :reject
    remove_column :issues, :accept_total
    remove_column :issues, :agree
    remove_column :issues, :disagree
    remove_column :issues, :agree_total
  end
end
