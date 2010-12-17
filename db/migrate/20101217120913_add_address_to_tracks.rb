class AddAddressToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :ip, :string
  end

  def self.down
    remove_column :tracks, :ip
  end
end
