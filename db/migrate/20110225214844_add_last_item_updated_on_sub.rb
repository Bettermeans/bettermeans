class AddLastItemUpdatedOnSub < ActiveRecord::Migration
  def self.up
    add_column :projects, :last_item_sub_updated_on, :datetime
    Project.all.each {|p| p.update_attribute(:last_item_sub_updated_on, p.last_item_updated_on)}
  end

  def self.down
    drop_column :projects, :last_item_sub_updated_on, :datetime
  end
end
