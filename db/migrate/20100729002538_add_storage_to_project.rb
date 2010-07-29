class AddStorageToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :storage, :float
  end

  def self.down
    remove_column :projects, :storage
  end
end
