require 'spec_helper'

describe User, '.current=' do

  let(:user) { User.new }

  after(:each) do
    User.current = nil
  end

  it "sets the user for the current thread" do
    User.current = user
    User.current.should == user
  end

  it "does not set the user on another thread" do
    User.current = user
    Thread.new { User.current.should_not == user }.join
  end

end
