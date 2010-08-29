class AddPrivateColumnToActivityStream < ActiveRecord::Migration
  def self.up
    add_column :activity_streams, :is_public, :boolean, :default => false
    ActivityStream.all.each do |as|
      if as.project
        as.is_public = as.project.is_public
        as.save
      end
    end
  end

  def self.down
    remove_column :activity_streams, :is_public
  end
end
