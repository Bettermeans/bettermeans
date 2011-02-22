class CreateEmailUpdates < ActiveRecord::Migration
  def self.up
    create_table :email_updates do |t|
      t.integer :user_id
      t.string :mail
      t.string :token
      t.boolean :activated, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :email_updates
  end
end
