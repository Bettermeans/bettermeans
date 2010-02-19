class AddDppToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :dpp, :float #Dollars per point
  end

  def self.down
    remove_column :projects, :dpp
  end
end
