class AddExpirationDateToMotions < ActiveRecord::Migration
  def self.up
    add_column :motions, :ends_on, :date
  end

  def self.down
    remove_column :motions, :ends_on
  end
end
