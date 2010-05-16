class DropTimeEntries < ActiveRecord::Migration
  def self.up
    drop_table :time_entries
  end

  def self.down
  end
end
