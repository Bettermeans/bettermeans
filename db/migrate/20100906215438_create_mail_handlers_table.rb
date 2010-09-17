class CreateMailHandlersTable < ActiveRecord::Migration
  def self.up
    create_table :mail_handlers do |t|
      t.datetime  :created_at
      t.datetime  :updated_at
    end
    
  end

  def self.down
    drop_table :mail_handlers
  end
end
