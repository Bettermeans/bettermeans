class DropRepositories < ActiveRecord::Migration
  def self.up
    drop_table :repositories
    drop_table :changes
    drop_table :changesets
    drop_table :changesets_issues
  end

  def self.down
  end
end
