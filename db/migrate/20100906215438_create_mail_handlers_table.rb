class CreateMailHandlersTable < ActiveRecord::Migration
  def self.up
    create_table :mail_handlers do |t|
      t.datetime  :created_on
      t.datetime  :updated_on
    end
    
  end

  def self.down
    drop_table :mail_handlers
  end
end
