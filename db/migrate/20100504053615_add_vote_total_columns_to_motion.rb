class AddVoteTotalColumnsToMotion < ActiveRecord::Migration
  def self.up
    add_column :motions, :agree, :integer, :default => 0
    add_column :motions, :disagree, :integer, :default => 0
    add_column :motions, :agree_total, :integer, :default => 0
    add_column :motions, :agree_nonbind, :integer, :default => 0
    add_column :motions, :disagree_nonbind, :integer, :default => 0
    add_column :motions, :agree_total_nonbind, :integer, :default => 0
  end

  def self.down
    remove_column :motions, :agree
    remove_column :motions, :disagree
    remove_column :motions, :agree_total
    remove_column :motions, :agree_nonbind
    remove_column :motions, :disagree_nonbind
    remove_column :motions, :agree_total_nonbind
  end
end
