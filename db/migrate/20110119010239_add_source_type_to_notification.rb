class AddSourceTypeToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :source_type, :string, :default => nil
  end

  def self.down
    remove_column :notifications, :source_type
  end
end
