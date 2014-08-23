require 'spec_helper'

describe User, '#registered?' do

  let(:user) { User.new }

  context "when user status is registered" do
    it "returns true" do
      user.status = User::STATUS_REGISTERED
      user.registered?.should be true
    end
  end

  context "when user status is not registered" do
    it "returns false" do
      user.status = User::STATUS_ACTIVE
      user.registered?.should be false
    end
  end

end
