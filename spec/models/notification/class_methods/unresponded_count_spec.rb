require 'spec_helper'

describe Notification, '.unresponded_count' do

  it "returns how many notifications are unresponded" do
    notification = Notification.create!({ :recipient => User.current})
    Notification.unresponded_count.should == 1
  end

end
