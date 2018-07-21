require 'spec_helper'

describe User, '.find_by_login' do

  let(:user) { Factory.build(:user) }

  it "finds a user by their login" do
    user.update_attributes!(:login => "Leigh")
    User.find_by_login("Leigh").should == user
  end

  it "finds a user by their login case insensitive" do
    user.update_attributes!(:login => "Leigh")
    User.find_by_login("lEIGH").should == user
  end

  it "BUG? finds the anonymous user when login is nil" do
    user = User.anonymous
    User.find_by_login(nil).should == user
  end

end