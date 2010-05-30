class CreateHourlyTypes < ActiveRecord::Migration
  def self.up
    create_table :hourly_types do |t|
      t.integer :project_id
      
      t.string  :name
      t.decimal :hourly_rate_per_person, :precision => 8, :scale => 2
      t.decimal :hourly_cap,             :precision => 8, :scale => 2
      
      t.timestamps
    end
  end

  def self.down
    drop_table :hourly_types
  end
end
