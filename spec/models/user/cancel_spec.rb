require 'spec_helper'

describe User, '#cancel' do

  let(:user) { Factory.create(:user, :mail => 'blah@blue.com') }

  it "updates the user status to canceled" do
    user.cancel
    user.reload.status.should == User::STATUS_CANCELED
  end

  it "updates the user email with a canceled string" do
    user.cancel
    mail, domain, status, number = user.reload.mail.split('.')
    "#{mail}.#{domain}".should == 'blah@blue.com'
    status.should == 'canceled'
    Integer(number).should < 1000
  end

end
