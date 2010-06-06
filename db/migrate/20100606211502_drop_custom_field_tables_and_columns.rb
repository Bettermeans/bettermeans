class DropCustomFieldTablesAndColumns < ActiveRecord::Migration
  def self.up
    drop_table :custom_values
    drop_table :custom_fields
    drop_table :custom_fields_projects
    drop_table :custom_fields_trackers
  end

  def self.down
  end
end
