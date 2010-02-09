class AddSenderIdToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :sender_id, :integer
  end

  def self.down
    remove_column :notifications, :sender_id
  end
end
