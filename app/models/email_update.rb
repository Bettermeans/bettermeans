class EmailUpdate < ActiveRecord::Base
  belongs_to :user

  def before_create # heckle_me
    self.token = Token.generate_token_value
  end

  def send_activation # heckle_me
    Mailer.send_later(:deliver_email_update_activation,self)
  end

  def accept # heckle_me
    self.update_attribute(:activated, true)
    self.user.update_attribute(:mail, self.mail)
  end

end
