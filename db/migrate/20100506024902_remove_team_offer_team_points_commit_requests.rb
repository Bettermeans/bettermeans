class RemoveTeamOfferTeamPointsCommitRequests < ActiveRecord::Migration
  
  def self.up
    drop_table :team_offers
    drop_table :team_points
    drop_table :commit_requests
  end
  
  def self.down
  end
end
