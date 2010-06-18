class CreateHourlyWorkItems < ActiveRecord::Migration
  def self.up
    add_column :issues, :hourly_type_id, :integer
    add_column :issues, :num_hours,      :integer, :default => 0
    Issue.update_all "hourly_type_id = NULL, num_hours = 0"
  end

  def self.down
    remove_column :issues, :hourly_type_id
    remove_column :issues, :num_hours
  end
end
