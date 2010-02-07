class AddTotalPointsColumnToRetro < ActiveRecord::Migration
  def self.up
    add_column :retros, :total_points, :integer
  end

  def self.down
    remove_column :retros, :total_points
  end
end
