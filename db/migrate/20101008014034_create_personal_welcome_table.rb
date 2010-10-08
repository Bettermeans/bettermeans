class CreatePersonalWelcomeTable < ActiveRecord::Migration
  def self.up
    create_table :personal_welcomes do |t|
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :personal_welcomes
  end
end
