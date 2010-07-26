class AddVolunteerColumnToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :volunteer, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :volunteer
  end
end
