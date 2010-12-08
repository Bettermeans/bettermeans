class AddNewMailToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :new_mail, :string
  end

  def self.down
    remove_column :invitations, :new_mail
  end
end
