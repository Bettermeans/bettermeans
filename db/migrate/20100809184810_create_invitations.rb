class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :user_id
      t.integer :project_id
      t.string :token
      t.integer :status, :default => Invitation::PENDING
      t.integer :role_id, :defulat => Role::BUILTIN_CONTRIBUTOR
      t.string  :mail

      t.datetime  :created_on
      t.datetime  :updated_on
    end
  end

  def self.down
    drop_table :invitations
  end
end
