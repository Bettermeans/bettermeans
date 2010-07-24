class AddIdentifierToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :identifier, :string
  end

  def self.down
    remove_column :users, :identifier
  end
end