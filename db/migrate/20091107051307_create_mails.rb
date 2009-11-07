class CreateMails < ActiveRecord::Migration
  def self.up
    create_table :mails do |t|
      t.integer :sender_id, :recipient_id
      t.boolean :sender_deleted, :recipient_deleted, :default => false
      t.string :subject
      t.text :body
      t.datetime :read_at
      t.timestamps
    end
  end

  def self.down
    drop_table mails
  end
end