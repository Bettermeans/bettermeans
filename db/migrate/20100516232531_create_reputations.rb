class CreateReputations < ActiveRecord::Migration
  def self.up
    create_table :reputations do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :reputation_type
      t.float :value
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :reputations
  end
end
