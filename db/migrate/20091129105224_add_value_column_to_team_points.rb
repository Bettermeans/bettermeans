class AddValueColumnToTeamPoints < ActiveRecord::Migration
  def self.up    
    add_column :team_points, :value, :integer, :default => 1
    add_index :team_points, [:author_id]
    add_index :team_points, [:recipient_id]
    add_index :team_points, [:project_id]
  end

  def self.down
    remove_column :team_points, :value
    remove_index :team_points, :name => :index_team_points_on_author_id
    remove_index :team_points, :name => :index_team_points_on_recipient_id
    remove_index :team_points, :name => :index_team_points_on_project_id
  end
end
