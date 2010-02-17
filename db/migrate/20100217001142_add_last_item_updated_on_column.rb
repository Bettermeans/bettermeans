class AddLastItemUpdatedOnColumn < ActiveRecord::Migration
  def self.up
    add_column :projects, :last_item_updated_on, :datetime
  end

  def self.down
    remove_column :projects, :last_item_updated_on
  end
end
