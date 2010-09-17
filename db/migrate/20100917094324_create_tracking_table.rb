class CreateTrackingTable < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.integer :user_id
      t.integer :code
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
