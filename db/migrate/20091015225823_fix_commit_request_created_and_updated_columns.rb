class FixCommitRequestCreatedAndUpdatedColumns < ActiveRecord::Migration
  def self.up
    rename_column :commit_requests, :created_at, :created_on
    rename_column :commit_requests, :updated_at, :updated_on
  end

  def self.down
    rename_column :commit_requests, :created_on, :created_at
    rename_column :commit_requests, :updated_on, :updated_at    
  end
end
