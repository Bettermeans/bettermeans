class AddTeamOffersTable < ActiveRecord::Migration
  def self.up
    create_table :team_offers do |t|
      t.integer  :response, :default => 0
      t.integer  :variation
      t.datetime :expires, :default => Time.now.advance(:months => 1)
      t.integer  :recipient_id
      t.integer  :project_id
      t.integer  :author_id
    end
    add_index :team_offers, [:author_id]
    add_index :team_offers, [:recipient_id]
    add_index :team_offers, [:project_id]
  end

  def self.down
    drop_table :team_offers
  end
end
