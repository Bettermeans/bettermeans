class DropEstimateAndPriTables < ActiveRecord::Migration
  def self.up
    drop_table :estimates
    drop_table :pris
  end

  def self.down
  end
end
