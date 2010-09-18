class CreateSharesAndCreditTables < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.float    :amount, :null => false
      t.datetime :expires
      t.integer  :variation, :default => 2, :null => false
      t.datetime :issued_on, :default => Time.now
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :project_id
      t.integer  :owner_id
    end
    add_index :shares, [:owner_id]
    add_index :shares, [:project_id]
    
    create_table :credits do |t|
      t.float    :amount, :null => false
      t.datetime :issued_on, :default => Time.now
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :owner_id
      t.integer  :project_id
    end
    add_index :credits, [:owner_id]
    add_index :credits, [:project_id]
    
  end

  def self.down
    drop_table :shares
    drop_table :credits
  end
end
