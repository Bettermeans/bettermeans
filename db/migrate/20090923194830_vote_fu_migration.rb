class VoteFuMigration < ActiveRecord::Migration
  def self.up
    create_table :votes, :force => true do |t|
      t.boolean    :vote, :default => false
      t.references :voteable, :polymorphic => true, :null => false
      t.references :voter,    :polymorphic => true
      t.timestamps      
    end

    add_index :votes, ["voter_id", "voter_type"],       :name => "fk_voters"
    add_index :votes, ["voteable_id", "voteable_type"], :name => "fk_voteables"

    # If you want to enfore "One Person, One Vote" rules in the database, uncomment the index below
    add_index :votes, ["voter_id", "voter_type", "voteable_id", "voteable_type"], :unique => true, :name => "uniq_one_vote_only"
  end

  def self.down
    drop_table :votes
  end

end
