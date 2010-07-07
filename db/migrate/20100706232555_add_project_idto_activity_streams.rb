class AddProjectIdtoActivityStreams < ActiveRecord::Migration
  def self.up
    add_column :activity_streams, :project_id, :integer, :default => 0
  end

  def self.down
    remove_column :activity_streams, :project_id
  end
end
