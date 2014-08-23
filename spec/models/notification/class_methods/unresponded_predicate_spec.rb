require 'spec_helper'

describe Notification, '.unresponded?' do

  let(:user) { Factory.create(:user) }

  before(:each) { User.stub(:current).and_return(user) }

  context "when no unresponded notification" do
    it "returns false" do
      Notification.unresponded?.should == false
    end
  end

  context "when one unresponded notification" do
    it "returns true" do
      Notification.create!({ :recipient => user})
      Notification.unresponded?.should == true
    end
  end

  context "when one expired notification" do
    it "returns false" do
      Notification.create!({ :recipient => user, :expiration => 5.days.ago })
      Notification.unresponded?.should == false
    end
  end

  context "when one archived notification" do
    it "returns false" do
      Notification.create!({ :recipient => user, :state => Notification::STATE_ARCHIVED})
      Notification.unresponded?.should == false
    end
  end

end
