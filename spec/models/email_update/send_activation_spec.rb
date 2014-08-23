require 'spec_helper'

describe EmailUpdate, '#send_activation' do

  let(:email_update) { EmailUpdate.create!(:activated => false) }

  before(:each) { Mailer.stub(:send_later) }

  it 'should deliver activation email' do
    Mailer.should_receive(:send_later).with(:deliver_email_update_activation, email_update)
    email_update.send_activation
  end

end
