class CreateUserColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :usage_over_at, :datetime, :default => nil
    add_column :users, :trial_expired_at, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :usage_over_at
    remove_column :users, :trial_expired_at
  end
end
