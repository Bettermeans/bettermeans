require 'spec_helper'

describe User, '.sysadmin' do

  let(:user) { User.find_by_login("admin") }

  it "returns the user with the login admin" do
    User.sysadmin.should == user
  end

  it "returns nil when no user with the login admin is found" do
    user.update_attributes!(:login => "boogers")
    User.sysadmin.should be nil
  end

end
