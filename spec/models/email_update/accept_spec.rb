require 'spec_helper'

describe EmailUpdate, '#accept' do

  let(:email_update) { EmailUpdate.create!(:activated => false) }

  before(:each) { Mailer.stub(:send_later) }

  before(:each) do
    user = Factory.create(:user)
    email_update.user = user
    email_update.mail = "some_mail"
  end

  it 'updates activation attributes to true' do
    email_update.accept
    email_update.activated.should be true
  end

  it 'updates mail attributes to mail' do
    email_update.accept
    email_update.user.mail.should == email_update.mail
  end

end
