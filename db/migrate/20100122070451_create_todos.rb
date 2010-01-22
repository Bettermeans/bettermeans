class CreateTodos < ActiveRecord::Migration
  def self.up
    create_table :todos do |t|
      t.string :subject
      t.integer :author_id
      t.integer :owner_id
      t.integer :issue_id
      t.datetime :completed_on
      t.datetime :created_on
      t.datetime :updated_on
    end
    
    add_index :todos, [:author_id]
    add_index :todos, [:owner_id]
    
  end

  def self.down
    drop_table :todos
  end
end
