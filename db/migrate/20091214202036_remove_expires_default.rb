class RemoveExpiresDefault < ActiveRecord::Migration
  def self.up
    change_column :team_offers, :expires, :datetime, :default => nil
  end

  def self.down
    change_column :team_offers, :expires, :datetime, :default => Time.now
  end
end
