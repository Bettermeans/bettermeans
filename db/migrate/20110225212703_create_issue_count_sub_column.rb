class CreateIssueCountSubColumn < ActiveRecord::Migration
  def self.up
    add_column :projects, :issue_count_sub, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :projects, :issue_count_sub
  end
end
