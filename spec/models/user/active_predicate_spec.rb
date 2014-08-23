require 'spec_helper'

describe User, '#active?' do

  let(:user) { User.new }

  context "when user status is active" do
    it "returns true" do
      user.status = User::STATUS_ACTIVE
      user.active?.should be true
    end
  end

  context "when user status is not active" do
    it "returns false" do
      user.status = User::STATUS_CANCELED
      user.active?.should be false
    end
  end

end
