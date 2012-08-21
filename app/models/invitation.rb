class Invitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :role

  PENDING = 0
  ACCEPTED = 1

  def before_create
    # TODO: check for dupes?
    self.token = Token.generate_token_value
    # TODO: should be `self.role ||= Role.contributor`
    self.role_id = Role.contributor.id unless self.role_id
  end

  def deliver(note="")
    return unless self.status == PENDING

    Mailer.send(:deliver_invitation_add,self,note)

    # add notification here
    # TODO: don't send email, once notifications are auto-sending emails
    recipient = User.find_by_mail(self.mail)

    Notification.create :recipient_id => recipient.id,
                              :variation => 'invitation',
                              :params => {:role_name => self.role.name, :project_name => self.project.name, :project_id => self.project_id, :token => self.token, :note => note},
                              :sender_id => self.user_id,
                              :source_id => self.id,
                              :source_type => "Invitation" if recipient

  end

  def resend(note="")
    return unless self.status == PENDING
    Mailer.send_later(:deliver_invitation_remind,self,note)
    return true
  end

  def status_name
    case self.status
      when PENDING
        return "Pending"
      when ACCEPTED
        return "Accepted"
      else
        return "Unkown"
    end
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
      @user.add_to_project self.project, self.role
    else
      @user.add_to_project self.project, Role.active
      @user.add_to_project self.project.root, self.role
    end

    @user.add_to_project self.project, Role.clearance unless self.project.is_public?

    self.new_mail = @user.mail if @user.mail
    self.status = ACCEPTED
    self.save!

    Notification.delete_all(:variation => 'invitation', :source_id => self.id)
  end

end



