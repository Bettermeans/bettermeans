class AddSettingsUpdatedOn < ActiveRecord::Migration
  def self.up
    add_column :settings, :updated_at, :timestamp
    # set updated_at
    Setting.find(:all).each(&:save)
  end

  def self.down
    remove_column :settings, :updated_at
  end
end
