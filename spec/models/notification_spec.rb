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

end
