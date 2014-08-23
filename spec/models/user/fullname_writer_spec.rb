require 'spec_helper'

describe User, '#fullname=' do

  let(:user) { Factory.build(:user) }

  before(:each) do
    user.firstname = 'firstname'
    user.lastname = 'lastname'
  end

  context "when given nil" do
    it "does not change first & last name" do
      user.fullname = nil
      user.firstname.should == 'firstname'
      user.lastname.should == 'lastname'
    end
  end

  context "when given a string" do
    it "assigns first and last names" do
      user.fullname = 'full name'
      user.firstname.should == 'full'
      user.lastname.should == 'name'
    end
  end

end
