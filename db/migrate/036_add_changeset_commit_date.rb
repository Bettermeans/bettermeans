class AddChangesetCommitDate < ActiveRecord::Migration
  def self.up
    add_column :changesets, :commit_date, :date
  end

  def self.down
    remove_column :changesets, :commit_date
  end
end
