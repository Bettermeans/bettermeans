class EmailUpdate < ActiveRecord::Base
  belongs_to :user

  def before_create # spec_me cover_me heckle_me
    self.token = Token.generate_token_value
  end

  def send_activation # spec_me cover_me heckle_me
    Mailer.send_later(:deliver_email_update_activation,self)
  end

  def accept # spec_me cover_me heckle_me
    self.update_attribute(:activated, true)
    self.user.update_attribute(:mail, self.mail)
  end

end
