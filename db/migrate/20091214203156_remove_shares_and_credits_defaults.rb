class RemoveSharesAndCreditsDefaults < ActiveRecord::Migration
  def self.up
    change_column :credits, :issued_on, :datetime, :default => nil
    change_column :shares, :issued_on, :datetime, :default => nil
  end

  def self.down
  end
end
