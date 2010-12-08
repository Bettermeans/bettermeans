class Invitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :role
  
  PENDING = 0
  ACCEPTED = 1
  
  def before_create
    self.token = Token.generate_token_value
    self.role_id = Role.contributor.id
  end
  
  def deliver(note=nil)
    # Mailer.send_later(:invitation_add,self)
    Mailer.send_later(:deliver_invitation_add,self,note)
  end
  
  def accept
    return unless self.status == PENDING
    
    @user = User.find_by_mail(self.new_mail)
    return unless @user
    
    puts "ok"
    if self.project.root?
      puts "#{@user.inspect }is a community member of #{self.project.inspect}" if @user.community_member_of? self.project
      @user.add_to_project self.project, self.role_id unless @user.community_member_of? self.project
      puts "added to project"
    else
      @user.add_to_project self.project, Role.active.id
      @user.add_to_project self.project.root, self.role_id unless @user.community_member_of? self.project.root
      puts "already part of project"
    end
    
    @user.add_to_project self.project, Role.clearance.id unless self.project.is_public?
    
    self.status = ACCEPTED
    self.save!
  end
  
end




# == Schema Information
#
# Table name: invitations
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  project_id :integer
#  token      :string(255)
#  status     :integer         default(0)
#  role_id    :integer
#  mail       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

