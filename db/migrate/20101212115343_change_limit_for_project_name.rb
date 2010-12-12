class ChangeLimitForProjectName < ActiveRecord::Migration
  def self.up
    change_column :projects, :name, :string, :default => "", :limit => 50, :null => false
  end

  def self.down
    change_column :projects, :name, :string, :default => "", :limit => 30, :null => false
  end
end
