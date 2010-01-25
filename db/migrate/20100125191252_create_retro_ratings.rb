class CreateRetroRatings < ActiveRecord::Migration
  def self.up
    create_table :retro_ratings do |t|
      t.integer  :rater_id
      t.integer  :ratee_id
      t.float    :score
      t.integer  :retro_id
      t.datetime :created_on
      t.datetime :updated_on
    end
    
    add_index :retro_ratings, [:rater_id]
    add_index :retro_ratings, [:ratee_id]
  end

  def self.down
    drop_table :retro_ratings
  end
end
