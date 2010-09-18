class CreatePlansTable < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string    :name
      t.integer   :code
      t.text      :description
      t.float     :amount
      t.integer   :storage_max
      t.integer   :contributor_max
      t.integer   :private_workstream_max
      t.integer   :public_workstream_max
      t.datetime  :created_at
      t.datetime  :updated_at
    end
    
    add_column :users, :plan_id, :integer, :default => 1
    User.update_all "plan_id = 1"
  end

  def self.down
    drop_table :plans
    remove_column :users, :plan_id
  end
end
