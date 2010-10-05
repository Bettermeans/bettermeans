class AddActivityTotalToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :activity_total, :integer
  end

  def self.down
    remove_column :projects, :activity_total
  end
end
