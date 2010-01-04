class CreateEstimateTable < ActiveRecord::Migration
  def self.up
    create_table :estimates do |t|
      t.integer  :points, :null => false
      t.integer  :user_id, :null => false
      t.integer  :issue_id, :null => false
      t.datetime :created_on
      t.datetime :updated_on
    end
    add_index :estimates, [:user_id]
    add_index :estimates, [:issue_id]
  end

  def self.down
    drop_table :estimates
  end
end
