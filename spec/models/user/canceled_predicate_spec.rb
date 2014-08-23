require 'spec_helper'

describe User, '#canceled?' do

  let(:user) { User.new }

  context "when user status is canceled" do
    it "returns true" do
      user.status = User::STATUS_CANCELED
      user.canceled?.should be true
    end
  end

  context "when user status is not canceled" do
    it "returns false" do
      user.status = User::STATUS_ACTIVE
      user.canceled?.should be false
    end
  end

end
