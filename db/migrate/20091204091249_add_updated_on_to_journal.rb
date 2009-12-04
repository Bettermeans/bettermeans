class AddUpdatedOnToJournal < ActiveRecord::Migration
  def self.up
    add_column :journals, :updated_on, :datetime
    Journal.update_all "updated_on = created_on"
  end

  def self.down
    remove_column :journals, :updated_on
  end
end
