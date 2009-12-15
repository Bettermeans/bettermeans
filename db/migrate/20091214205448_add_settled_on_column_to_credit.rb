class AddSettledOnColumnToCredit < ActiveRecord::Migration
  def self.up
    add_column :credits, :settled_on, :datetime    
    add_column :credits, :enabled, :boolean, :default => true
  end

  def self.down
    remove_column :credits, :settled_on
    remove_column :credits, :enabled
  end
end
