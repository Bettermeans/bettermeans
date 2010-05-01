class AddTopicColumnToMotions < ActiveRecord::Migration
  def self.up
    add_column :motions, :topic_id, :integer
  end

  def self.down
    remove_column :motions, :topic_id
  end
end
