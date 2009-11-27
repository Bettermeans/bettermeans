class AddTeamPoints < ActiveRecord::Migration
  def self.up
    create_table :team_points do |t|
      t.integer  :project_id
      t.integer  :author_id
      t.integer  :recipient_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down    
    drop_table :team_points
  end
  
end
