class AddConcernsUserToMotions < ActiveRecord::Migration
  def self.up
    add_column :motions, :concerned_user_id, :integer #For motions that are concerning a user being voted on (moving into or out of a role)
  end

  def self.down
    remove_column :motions, :concerned_user_id
  end
end
