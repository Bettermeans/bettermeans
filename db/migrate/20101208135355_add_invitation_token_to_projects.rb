class AddInvitationTokenToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :invitation_token, :string
    
    Project.all.each do |p|
      p.invitation_token = Token.generate_token_value
      p.save
    end
  end

  def self.down
    remove_column :projects, :invitation_token
  end
end
