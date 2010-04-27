class AddConfidenceToRetroRating < ActiveRecord::Migration
  def self.up
    add_column :retro_ratings, :confidence, :integer, :default => 100
    RetroRating.update_all(:confidence => 100)
  end

  def self.down
    remove_column :retro_ratings, :confidence
  end
end
