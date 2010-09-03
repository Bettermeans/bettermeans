class AddTrialExpired < ActiveRecord::Migration
  def self.up
    add_column :users, :trial_expires_on, :datetime
  end

  def self.down
    remove_column :users, :trial_expires_on, :datetime
  end
end
