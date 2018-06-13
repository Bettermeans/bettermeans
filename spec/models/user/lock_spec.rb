require 'spec_helper'

describe User, '#lock' do

  let(:user) { Factory.create(:user) }

   it "updates the user status to status_locked" do
    user.lock
    user.reload.status.should == User::STATUS_LOCKED
  end

end
