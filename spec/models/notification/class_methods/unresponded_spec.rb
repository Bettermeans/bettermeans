require 'spec_helper'

describe Notification, '.unresponded' do

  it "Finds any notifications that are unresponded" do
    notification = Notification.create!({ :recipient => User.current})
    Notification.unresponded.should include(notification)
  end

end
