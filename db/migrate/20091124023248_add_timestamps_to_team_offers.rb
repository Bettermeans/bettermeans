class AddTimestampsToTeamOffers < ActiveRecord::Migration
  def self.up
    add_column :team_offers, :author_note, :text
    add_column :team_offers, :recipient_note, :text
    add_column :team_offers, :created_on, :datetime
    add_column :team_offers, :updated_on, :datetime
  end

  def self.down
    remove_column :team_offers, :author_note, :text
    remove_column :team_offers, :recipient_note, :text
    remove_column :team_offers, :created_on
    remove_column :team_offers, :updated_on
  end
end
