class AddsProjectActivityLine < ActiveRecord::Migration
  def self.up
    add_column :projects, :activity_line, :text, :default => '[]'
  end

  def self.down
    remove_column :projects, :activity_line
  end
end
