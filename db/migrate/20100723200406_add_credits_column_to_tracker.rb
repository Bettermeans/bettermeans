class AddCreditsColumnToTracker < ActiveRecord::Migration
  def self.up
    add_column :trackers, :for_credits_module, :boolean, :default => false
  end

  def self.down
    remove_column :trackers, :for_credits_module
  end
end
