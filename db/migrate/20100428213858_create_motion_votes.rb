class CreateMotionVotes < ActiveRecord::Migration
  def self.up
    create_table :motion_votes do |t|
      t.integer :motion_id
      t.integer :user_id
      t.integer :points
      t.boolean :isbinding, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :motion_votes
  end
end
