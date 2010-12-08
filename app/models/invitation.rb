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
  
  def deliver(note="")
    return unless self.status == PENDING
    
    # Mailer.send_later(:invitation_add,self)
    Mailer.send_later(:deliver_invitation_add,self,note)
    
    # add notification here
    # todo: don't send email, once notifications are auto-sending emails
    recipient = User.find_by_mail(self.mail)
    
    Notification.create :recipient_id => recipient.id,
                              :variation => 'invitation',
                              :params => {:role_name => self.role.name, :project_name => self.project.name, :project_id => self.project_id, :token => self.token, :note => note}, 
                              :sender_id => self.user_id,
                              :source_id => self.id if recipient
    
  end
  
  def accept(user=nil)
    return unless self.status == PENDING
    
    if user && !user.anonymous?
      @user = user
    elsif self.new_mail && !self.new_mail.empty?
      @user = User.find_by_mail(self.new_mail)
    else
      @user = User.find_by_mail(self.mail)
    end
    return unless @user && !@user.anonymous?
    
    if self.project.root?
      @user.add_to_project self.project, self.role_id unless @user.community_member_of? self.project
    else
      @user.add_to_project self.project, Role.active.id
      @user.add_to_project self.project.root, self.role_id unless @user.community_member_of? self.project.root
    end
    
    @user.add_to_project self.project, Role.clearance.id unless self.project.is_public?
    
    self.new_mail = @user.mail if @user.mail
    self.status = ACCEPTED
    self.save!
    
    Notification.delete_all(:variation => 'invitation', :source_id => self.id)
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

