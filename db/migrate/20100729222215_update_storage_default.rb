class UpdateStorageDefault < ActiveRecord::Migration
  def self.up
    change_column :projects, :storage, :float, :default => 0
  end

  def self.down
    change_column :projects, :storage, :float
  end
end
