require 'spec_helper'

describe User, '#before_create' do

  let(:user) { Factory.build(:user) }

  it "sets the user's plan to the free plan when not already set" do
    user.plan = nil
    user.save!
    user.plan.should == Plan.free
  end

  it "does not change the user's plan when it's already set" do
    plan = Factory.create(:plan, :name => "Expensive", :code => 52)
    user.plan = plan
    user.save!
    user.plan.should == plan
  end

  it "sets mail notifications to false" do
    user.mail_notification = true
    user.save!
    user.mail_notification.should == false
  end

  it "downcases the login" do
    user.login = "uSeRnAmE"
    user.save!
    user.login.should == "username"
  end

end
