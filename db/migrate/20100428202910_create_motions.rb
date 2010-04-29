class CreateMotions < ActiveRecord::Migration
  def self.up
    create_table :motions do |t|
      t.integer :project_id
      t.string :title
      t.text :description
      t.string :variation
      t.text :params
      t.integer :motion_type
      t.integer :state

      t.timestamps
    end
  end

  def self.down
    drop_table :motions
  end
end
