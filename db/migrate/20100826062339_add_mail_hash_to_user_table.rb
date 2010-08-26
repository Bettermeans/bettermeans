class AddMailHashToUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :mail_hash, :string
  end

  def self.down
    remove_column :users, :mail_hash
  end
end
