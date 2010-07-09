class AddGeneratedFieldsToActivityStream < ActiveRecord::Migration
  def self.up
    add_column :activity_streams, :actor_name, :string
    add_column :activity_streams, :object_name, :string
    add_column :activity_streams, :object_description, :text
    add_column :activity_streams, :indirect_object_name, :string
    add_column :activity_streams, :indirect_object_description, :text
  end

  def self.down
    remove_column :activity_streams, :actor_name
    remove_column :activity_streams, :object_name
    remove_column :activity_streams, :object_description
    remove_column :activity_streams, :indirect_object_name
    remove_column :activity_streams, :indirect_object_description
  end
end
