require 'spec_helper'

describe Notification, '#remove_mention_duplicates' do

  let(:user) { Factory.create(:user) }

  context "with mention" do
    it "archives prior matching notifications" do
      notification1 = Notification.create!({
        :variation => 'mention',
        :recipient => user,
        :source_id => 1,
        :source_type => 'test'
      })
      notification1.state.should == Notification::STATE_ACTIVE
      notification2 = Notification.create!({
        :variation => 'mention',
        :recipient => user,
        :source_id => 1,
        :source_type => 'test'
      })
      notification1.reload.state.should == Notification::STATE_ARCHIVED
    end
  end

  context "without mention" do
    it "doesn't archive prior notification if not mentioned" do
      notification1 = Notification.create!({
        :variation => 'mention',
        :recipient => user,
        :source_id => 1,
        :source_type => 'test'
      })
      notification1.state.should == Notification::STATE_ACTIVE
      notification2 = Notification.create!({
        :variation => 'not mention',
        :recipient => user,
        :source_id => 1,
        :source_type => 'test'
      })
      notification1.reload.state.should == Notification::STATE_ACTIVE
    end
  end

end
