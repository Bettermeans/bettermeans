class EmailUpdate < ActiveRecord::Base
  belongs_to :user

  def before_create
    self.token = Token.generate_token_value
  end

  def send_activation
    Mailer.send_later(:deliver_email_update_activation,self)
  end

  def accept
    self.update_attribute(:activated, true)
    self.user.update_attribute(:mail, self.mail)
  end

end
