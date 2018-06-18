require 'spec_helper'

describe User, '#activate' do

  let(:user) { User.new }

  it "sets the user status to active" do
    user.activate
    user.status.should == User::STATUS_ACTIVE
  end

end
