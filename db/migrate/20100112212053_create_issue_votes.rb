class CreateIssueVotes < ActiveRecord::Migration
  def self.up
    create_table :issue_votes do |t|
      t.integer  :points, :null => false
      t.integer  :user_id, :null => false
      t.integer  :issue_id, :null => false
      t.integer  :vote_type, :null => false
      t.datetime :created_on
      t.datetime :updated_on
    end
    
    add_index :issue_votes, [:user_id]
    add_index :issue_votes, [:issue_id]
    add_index :issue_votes, [:vote_type]
  end


  def self.down
    drop_table :issue_votes
  end
end