class ChangePointsToFloatInIssueVotes < ActiveRecord::Migration
  def self.up
    change_column :issue_votes, :points, :float
  end

  def self.down
    change_column :issue_votes, :points, :integer
  end
end
