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

  describe "##unresponded?" do
    context "when unresponded_count > 0" do
      it "returns true" do
        Notification.stub(:unresponded_count).and_return(1)
        Notification.unresponded?.should == true
      end
    end

    context "when unresponded_count <= 0" do
      it "returns false" do
        Notification.stub(:unresponded_count).and_return(0)
        Notification.unresponded?.should == false
      end
    end
  end

  describe "##unresponded_count" do
    it "calls ##count with a hash of conditions" do
      Notification.should_receive(:count) do |hash|
        hash.should be_a(Hash)
      end
      Notification.unresponded_count
    end
  end

  describe "##unresponded" do
    it "Finds any notifications that are unresponded" do
      Notification.should_receive(:find) do |all, hash|
        all.should == :all
        hash.should be_a(Hash)
      end
      Notification.unresponded
    end
  end

  describe "#remove_mention_duplicates" do
    let(:notification) { Notification.new }


    context "with mention" do
      it 'calls ##update_all' do
        notification.variation = 'mention'
        Notification.should_receive(:update_all)
        notification.remove_mention_duplicates
      end
    end

    context "without mention" do
      it 'does not call ##update_all' do
        notification.variation = 'not mention'
        Notification.should_not_receive(:update_all)
        notification.remove_mention_duplicates
      end
    end
  end

  describe "##recind" do
    let(:notification) { Notification.new }

    before(:each) do

      Notification.stub(:find).and_return([notification])
      Notification.stub(:save).and_return(true)

    end

    it "grabs a list of matching notifications" do
      Notification.should_receive(:find)
      Notification.recind('', '', '')
    end

    it "sets state of matched notifications to STATE_RECINDED" do
      notification.state.should_not == 3
      Notification.recind('', '', '')
      notification.state.should == 3
    end

    it "saves the notifications" do
      notification.should_receive(:save)
      Notification.recind('', '', '')
    end
  end
end
