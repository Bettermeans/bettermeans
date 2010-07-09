#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the migration for ActivityStreams
class CreateActivityStreams < ActiveRecord::Migration
  def self.up

    # Modify the User to have an activity_stream_token
    add_column :<%= user_model_table %>, :activity_stream_token, :string

    # The Activity Stream table
    create_table :activity_streams do |t|
      t.string :verb                            # The verb
      t.string :activity                        # The activity (grouping)
      t.integer :actor_id                       # Polymorphinc actor
      t.string :actor_type
      t.string :actor_name_method               # Method on the actor model
      t.integer :count, :default => 1           # Count
      t.integer :object_id                      # Polymorphic social object
      t.string :object_type
      t.string :object_name_method              # Method on the object name
      t.integer :indirect_object_id
      t.string :indirect_object_type            # Polymorphic indirect object
      t.string :indirect_object_name_method
      t.string :indirect_object_phrase
      t.integer :status, :default =>0    # 0=public;1=debug;2=internal;5=deleted

      t.timestamps
    end

    add_index :activity_streams, [:actor_id, :actor_type],
      :name => :activity_streams_by_actor
    add_index :activity_streams, [:object_id, :object_type],
      :name => :activity_streams_by_object
    add_index :activity_streams, [:indirect_object_id, :indirect_object_type],
      :name => :activity_streams_by_indirect_object

    create_table :activity_stream_totals do |t|
      t.string :activity
      t.integer :object_id
      t.string :object_type
      t.float :total, :default => 0, :limit => 25 # double precision

      t.timestamps
    end
    add_index :activity_stream_totals, [:activity, :object_id, 
      :object_type], :name => :activity_stream_totals_idx

    create_table :activity_stream_preferences do |t|
      t.string :activity
      t.string :location
      t.integer :<%= user_model_id %>

      t.timestamps
    end
    add_index :activity_stream_preferences, [:activity, :<%= user_model_id %>],
      :name => :activity_stream_preferences_idx

  end

  def self.down
    remove_column :<%= user_model_table %>, :activity_stream_token

    drop_table :activity_streams
    drop_table :activity_stream_totals
    drop_table :activity_stream_preferences
  end

end
