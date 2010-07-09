class AddTrackerNameToActionTable < ActiveRecord::Migration
  def self.up
    add_column :activity_streams, :tracker_name, :string
    add_column :activity_streams, :project_name, :string
    add_column :activity_streams, :actor_email, :string
  end

  def self.down
    remove_column :activity_streams, :tracker_name
    remove_column :activity_streams, :project_name
    remove_column :activity_streams, :actor_email
  end
end
