class ChangePointsToFloat < ActiveRecord::Migration
  def self.up
    change_column :issues, :points, :float
  end

  def self.down
        change_column :issues, :points, :integer
  end
end
