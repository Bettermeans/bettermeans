class AddAuthorToMotion < ActiveRecord::Migration
    def self.up
      add_column :motions, :author_id, :integer
    end

    def self.down
      remove_column :motions, :author_id
    end
  end
