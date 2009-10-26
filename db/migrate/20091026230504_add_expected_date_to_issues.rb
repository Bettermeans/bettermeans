class AddExpectedDateToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :expected_date, :date
  end

  def self.down
    remove_column :issues, :expected_date
  end
end
