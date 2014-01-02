require 'spec_helper'

describe EmailUpdate do
  it { should belong_to(:user) }

  let(:token) { Token.create! }
  let(:email_update) { EmailUpdate.create!(:activated => false) }

  before(:each) { Mailer.stub(:send_later) }

  describe '#send_activation' do
    it 'should deliver activation email' do
      Mailer.should_receive(:send_later).with(:deliver_email_update_activation, email_update)
      email_update.send_activation
    end
  end

  describe '#before_create' do
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

  describe '#accept' do
    before(:each) do
      user = Factory.create(:user)
      email_update.user = user
      email_update.mail = "some_mail"
    end

    it 'updates activation attributes to true' do
      email_update.accept
      email_update.activated.should be_true
    end

    it 'updates mail attributes to mail' do
      email_update.accept
      email_update.user.mail.should == email_update.mail
    end
  end

end
