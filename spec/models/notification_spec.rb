require "spec_helper"

describe Notification do

  describe "#mark_as_responded" do
    let(:notification) { Notification.new }

    it "sets the state to responded" do
      notification.state = Notification::STATE_ACTIVE
      notification.mark_as_responded
      notification.state.should == Notification::STATE_RESPONDED
    end

    it "sets the params to nil" do
      notification.params = 1
      notification.mark_as_responded
      notification.params.should == nil
    end

    it "saves the record" do
      notification.should_receive(:save)
      notification.mark_as_responded
    end
  end

  describe "#mention?" do
    let(:notification) { Notification.new }

    context "when notification type is a mention" do
      it "returns true" do
        notification.variation = "mention"
        notification.should be_mention
      end
    end

    context "when notification type is not a mention" do
      it "returns false" do
        notification.variation = "not mention"
        notification.should_not be_mention
      end
    end
  end

  describe ".unresponded?" do
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

  describe ".unresponded_count" do
    it "calls .count with a hash of conditions" do
      Notification.should_receive(:count) do |hash|
        hash.should be_a(Hash)
      end
      Notification.unresponded_count
    end
  end

  describe ".unresponded" do
    it "Finds any notifications that are unresponded" do
      notification = Notification.create!({ :recipient => User.current})
      Notification.unresponded.should include(notification)
    end
  end

  describe "#remove_mention_duplicates" do
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

  describe ".recind" do
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
end
