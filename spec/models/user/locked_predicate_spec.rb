require 'spec_helper'

describe User, '#locked?' do

  let(:user) { User.new }

  context "when user status is locked" do
    it "returns true" do
      user.status = User::STATUS_LOCKED
      user.locked?.should be true
    end
  end

  context "when user status is not locked" do
    it "returns false" do
      user.status = User::STATUS_ACTIVE
      user.locked?.should be false
    end
  end

end
