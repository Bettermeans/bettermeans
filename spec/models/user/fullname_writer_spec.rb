require 'spec_helper'

describe User, '#fullname=' do

  let(:user) { User.new(:firstname => 'sally', :lastname => 'bob') }

  context "when given nil" do
    it "does not change first & last name" do
      user.fullname = nil
      user.firstname.should == 'sally'
      user.lastname.should == 'bob'
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
