class CreateHourlyTypes < ActiveRecord::Migration
  def self.up
    create_table :hourly_types do |t|
      t.project_id
      t.string :name,       :null => false
      t.text   :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :hourly_types
  end
end
