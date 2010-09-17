class AddAndRenameCreatedAndUpdatedOn < ActiveRecord::Migration
  def self.up
    add_column :member_roles, :created_at, :datetime
    add_column :member_roles, :updated_at, :datetime
    change_column :member_roles, :member_id, :integer, :null => true
    change_column :member_roles, :role_id, :integer, :null => true
        
    rename_column :notifications, :created_at, :created_at
    rename_column :notifications, :expiration_date, :expiration
    rename_column :notifications, :updated_at, :updated_at
    change_column :notifications, :expiration, :datetime
    add_index :notifications, [:recipient_id]
    
    rename_column :team_points, :created_at, :created_at
    rename_column :team_points, :updated_at, :updated_at
  end

  def self.down
    remove_column :member_roles, :created_at
    remove_column :member_roles, :updated_at
    change_column :member_roles, :member_id, :integer, :null => false
    change_column :member_roles, :role_id, :integer, :null => false
        
    rename_column :notifications, :created_at, :created_at
    rename_column :notifications, :expiration, :expiration_date
    rename_column :notifications, :updated_at, :updated_at
    change_column :notifications, :expiration_date, :date
    remove_index :notifications, :name => :index_notifications_on_recipient_id
    
    rename_column :team_points, :created_at, :created_at
    rename_column :team_points, :updated_at, :updated_at
  end
end
