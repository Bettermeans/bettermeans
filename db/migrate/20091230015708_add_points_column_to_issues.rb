class AddPointsColumnToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :points, :integer
  end

  def self.down
    remove_column :issues, :points
  end
end
