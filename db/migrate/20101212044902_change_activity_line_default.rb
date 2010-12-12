class ChangeActivityLineDefault < ActiveRecord::Migration
  def self.up
    change_column_default(:projects,:activity_line, nil)
  end

  def self.down
  end
end
