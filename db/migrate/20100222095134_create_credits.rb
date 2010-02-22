class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.float :amount
      t.integer :owner_id
      t.integer :project_id
      t.boolean :enabled

      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
