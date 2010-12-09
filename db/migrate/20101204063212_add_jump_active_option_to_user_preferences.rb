class AddJumpActiveOptionToUserPreferences < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :active_only_jumps, :boolean, :default => true
  end

  def self.down
    remove_column :user_preferences, :active_only_jumps
  end
end
