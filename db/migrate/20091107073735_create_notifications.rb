class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :recipient_id
      t.string :variation #different types of notification
      t.text :params
      t.integer :state, :default => 0 #-1 is deactivated, 0 is active, 1 is responded, 2 is archived
      t.integer :source_id #id of object that the notification is about. For example, if a commit_request is issueing the notification, this is a good place to store the commit_request_id
      t.date :expiration_date
      t.timestamps
    end
    
  end

  def self.down
    drop_table :notifications
  end
end
