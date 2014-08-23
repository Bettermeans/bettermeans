require 'spec_helper'

describe Notification, '.recind' do

  it "sets state of matched notifications to STATE_RECINDED" do
    notification = Notification.create!({
      :variation => 'mention',
      :source_id => 1,
      :sender_id => 1
    })

    Notification.recind('mention', 1, 1)
    notification.reload.state.should == Notification::STATE_RECINDED
  end

end
