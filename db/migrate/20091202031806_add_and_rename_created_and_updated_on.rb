class AddAndRenameCreatedAndUpdatedOn < ActiveRecord::Migration
  def self.up
    add_column :member_roles, :created_on, :datetime
    add_column :member_roles, :updated_on, :datetime
    change_column :member_roles, :member_id, :integer, :null => true
    change_column :member_roles, :role_id, :integer, :null => true
        
    rename_column :notifications, :created_at, :created_on
    rename_column :notifications, :expiration_date, :expiration
    rename_column :notifications, :updated_at, :updated_on
    change_column :notifications, :expiration, :datetime
    add_index :notifications, [:recipient_id]
    
    rename_column :team_points, :created_at, :created_on
    rename_column :team_points, :updated_at, :updated_on
  end

  def self.down
    remove_column :member_roles, :created_on
    remove_column :member_roles, :updated_on
    change_column :member_roles, :member_id, :integer, :null => false
    change_column :member_roles, :role_id, :integer, :null => false
        
    rename_column :notifications, :created_on, :created_at
    rename_column :notifications, :expiration, :expiration_date
    rename_column :notifications, :updated_on, :updated_at
    change_column :notifications, :expiration_date, :date
    remove_index :notifications, :name => :index_notifications_on_recipient_id
    
    rename_column :team_points, :created_on, :created_at
    rename_column :team_points, :updated_on, :updated_at
  end
end
