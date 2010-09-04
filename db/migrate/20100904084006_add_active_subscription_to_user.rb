class AddActiveSubscriptionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active_subscription, :boolean, :default => false
  end

  def self.down
    remove_column :users, :active_subscription
  end
end
