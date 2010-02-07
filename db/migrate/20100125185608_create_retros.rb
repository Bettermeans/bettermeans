class CreateRetros < ActiveRecord::Migration
  def self.up
    create_table :retros do |t|
      t.integer   :status_id
      t.integer   :project_id
      t.datetime  :from_date
      t.datetime  :to_date
      t.datetime  :created_on
      t.datetime  :updated_on
    end
    
    add_column :issues, :retro_id, :integer
    add_index :retros, [:project_id]
    
  end

  def self.down
    drop_table :retros
    remove_column :issues, :retro_id
  end
end
