class RenameCreatedonToUpdatedOn < ActiveRecord::Migration
  def self.up
    rename_column :, :created_on, :updated_on
    rename_column :, :updated_on, :created_on
    
  end

  def self.down
  end
end
