class CreateHelpSections < ActiveRecord::Migration
  def self.up
    create_table :help_sections do |t|
      t.integer :user_id, :default => 0, :null => false
      t.string :name 
      t.boolean :show, :default => true
      t.datetime  :created_at
      t.datetime  :updated_at
    end
  end

  def self.down
    drop_table :help_sections
  end
end
