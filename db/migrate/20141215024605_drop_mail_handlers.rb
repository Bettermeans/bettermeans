class DropMailHandlers < ActiveRecord::Migration

  def self.up
    drop_table :mail_handlers
  end

  def self.down
    create_table :mail_handlers do |t|
      t.timestamps
    end
  end

end
