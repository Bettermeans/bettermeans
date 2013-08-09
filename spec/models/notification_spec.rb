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
    it "" do
    end
  end

end
