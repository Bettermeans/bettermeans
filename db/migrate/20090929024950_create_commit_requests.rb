class CreateCommitRequests < ActiveRecord::Migration
  def self.up
    create_table :commit_requests do |t|
      t.integer :user_id, :default => 0, :null => false
      t.integer :issue_id, :default => 0, :null => false
      t.integer :days, :default => 0 #Number of days commitment is made for (-1 is infinity, 0 is undefined)
      t.integer :responder_id, :default => 0, :null => true #Id of user who responded. If same user recinded request, then their id is in the recinding as well
      t.integer :response, :default => 0, :null => false # 0- Request No response 1-Request recinded 2-Request Declined 3-Request Accepted 4-Offer no response 5-Offer recinded 6-Offer accepted 7-Offer Declined
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commit_requests
  end
end
