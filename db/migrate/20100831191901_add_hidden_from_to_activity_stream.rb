class AddHiddenFromToActivityStream < ActiveRecord::Migration
  def self.up
    add_column :activity_streams, :hidden_from_user_id, :integer, :default => 0
    ActivityStream.update_all(:hidden_from_user_id => 0)
  end

  def self.down
    remove_column :activity_streams, :hidden_from_user_id
  end
end
