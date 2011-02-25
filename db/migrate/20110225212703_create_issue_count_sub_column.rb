class CreateIssueCountSubColumn < ActiveRecord::Migration
  def self.up
    add_column :projects, :issue_count_sub, :integer, :default => 0, :null => false
    Project.all.each {|p| p.refresh_issue_count}
  end

  def self.down
    remove_column :projects, :issue_count_sub
  end
end
