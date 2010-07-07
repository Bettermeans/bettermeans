class RemoveGroupUsers < ActiveRecord::Migration
  def self.up
    drop_table :groups_users
  end

  def self.down
  end
end
