class AddBindingColulmn < ActiveRecord::Migration
  def self.up
    add_column :issue_votes, :isbinding, :boolean, :default => false
  end

  def self.down
    remove_column :issue_votes, :isbinding
  end
end
