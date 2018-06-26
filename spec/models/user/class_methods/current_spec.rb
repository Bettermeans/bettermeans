require 'spec_helper'

describe User, '.current' do

  let(:user) { User.new }

  after(:each) do
    User.current = nil
  end

  it "returns the user for the current thread" do
    User.current = user
    User.current.should == user
  end

  it "returns anonymous user when no user for the current thread" do
    User.current = nil
    User.current.should == User.anonymous
  end

  it "does not return a user set on another thread" do
    User.current = user
    Thread.new { User.current.should == User.anonymous }.join
  end

end
