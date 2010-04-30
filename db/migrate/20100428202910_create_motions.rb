class CreateMotions < ActiveRecord::Migration
  def self.up
    create_table :motions do |t|
      t.integer :project_id
      t.string :title
      t.text :description
      t.text :params
      t.integer :variation, :default => Motion::VARIATION_GENERAL
      t.integer :motion_type, :default => Motion::TYPE_MAJORITY
      t.integer :visibility_level, :default => Motion::VISIBLE_USER
      t.integer :binding_level, :default => Motion::BINDING_USER
      t.integer :state, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :motions
  end
end
