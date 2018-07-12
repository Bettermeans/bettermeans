require 'spec_helper'

describe User, '.find_by_mail' do

  let(:user) { Factory.build(:user) }

  it "finds a user by their mail" do
    user.update_attributes!(:mail => "email@example.com")
    User.find_by_mail("email@example.com").should == user
  end

  it "finds a user by their mail case insensitive" do
    user.update_attributes!(:mail => "EMAIL@example.com")
    User.find_by_mail("email@EXAMPLE.COM").should == user
  end

  it "BUG? finds the anonymous user when mail is nil" do
    user = User.anonymous
    User.find_by_mail(nil).should == user
  end
end
