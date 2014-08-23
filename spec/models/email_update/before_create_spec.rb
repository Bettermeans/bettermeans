require 'spec_helper'

describe EmailUpdate, '#before_create' do

  let(:token) { Token.create! }
  let(:email_update) { EmailUpdate.create!(:activated => false) }

  before(:each) { Mailer.stub(:send_later) }

  it "sets the token value" do
    ActiveSupport::SecureRandom.stub(:hex).and_return('hex')
    token.before_create
    token.value.should == 'hex'
  end

  it "should delete previous matching tokens" do
    previous = Token.create!({:user_id => 2})
    Token.create!({:user_id => 2})
    Token.find_by_id(previous.id).should == nil
  end

end
