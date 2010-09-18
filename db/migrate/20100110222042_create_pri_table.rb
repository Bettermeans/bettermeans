class CreatePriTable < ActiveRecord::Migration
  def self.up
    create_table :pris do |t|
      t.integer  :user_id
      t.integer :issue_id
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_index :pris, :user_id
    add_index :pris, :issue_id
    add_column :issues, :pri, :integer, :default => 0
    
    Issue.update_all(:pri => 0)
    
  end

  def self.down
    remove_index :pris, :user_id
    remove_index :pris, :issue_id
    drop_table :pris
    remove_column :issues, :pri
  end
end
