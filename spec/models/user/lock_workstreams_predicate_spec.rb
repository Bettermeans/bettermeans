require 'spec_helper'

describe User, '#lock_workstreams?' do

  let(:user) { Factory.build(:user) }

  it "returns false when usage and trial are not over" do
    user.lock_workstreams?.should be false
  end

  it "returns false when usage is over but not past the grace period" do
    user.usage_over_at = 1.day.ago
    user.lock_workstreams?.should be false
  end

  it "returns true when usage is over and past the grace period" do
    user.usage_over_at = 31.days.ago
    user.lock_workstreams?.should be true
  end

  it "returns false when trial is expired but not past the grace period" do
    user.trial_expired_at = 1.day.ago
    user.lock_workstreams?.should be false
  end

  it "returns true when trial is expired and past the grace period" do
    user.trial_expired_at = 31.days.ago
    user.lock_workstreams?.should be true
  end

end