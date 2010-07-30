class ChangeDppDefault < ActiveRecord::Migration
  def self.up
    change_column :projects, :dpp, :float, :default => 100
  end

  def self.down
    change_column :projects, :dpp, :float    
  end
end
