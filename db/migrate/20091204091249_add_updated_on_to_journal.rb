class AddUpdatedOnToJournal < ActiveRecord::Migration
  def self.up
    add_column :journals, :updated_at, :datetime
    Journal.update_all "updated_at = created_at"
  end

  def self.down
    remove_column :journals, :updated_at
  end
end
