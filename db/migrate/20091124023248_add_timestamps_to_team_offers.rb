class AddTimestampsToTeamOffers < ActiveRecord::Migration
  def self.up
    add_column :team_offers, :author_note, :text
    add_column :team_offers, :recipient_note, :text
    add_column :team_offers, :created_at, :datetime
    add_column :team_offers, :updated_at, :datetime
  end

  def self.down
    remove_column :team_offers, :author_note, :text
    remove_column :team_offers, :recipient_note, :text
    remove_column :team_offers, :created_at
    remove_column :team_offers, :updated_at
  end
end
