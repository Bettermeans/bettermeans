class CreateCommitRequests < ActiveRecord::Migration
  def self.up
    create_table :commit_requests do |t|
      t.integer :user_id, :default => 0, :null => false
      t.integer :issue_id, :default => 0, :null => false
      t.integer :response, :default => 0, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commit_requests
  end
end
