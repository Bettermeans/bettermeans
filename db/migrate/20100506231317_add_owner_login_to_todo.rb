class AddOwnerLoginToTodo < ActiveRecord::Migration
  def self.up
    add_column :todos, :owner_login, :string
  end

  def self.down
    remove_column :todos, :owner_login
  end
end
