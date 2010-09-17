class FixCommitRequestCreatedAndUpdatedColumns < ActiveRecord::Migration
  def self.up
    rename_column :commit_requests, :created_at, :created_at
    rename_column :commit_requests, :updated_at, :updated_at
  end

  def self.down
    rename_column :commit_requests, :created_at, :created_at
    rename_column :commit_requests, :updated_at, :updated_at    
  end
end
