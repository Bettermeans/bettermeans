require 'spec_helper'

describe Notification, '#mention?' do

  let(:notification) { Notification.new }

  context "when notification type is a mention" do
    it "returns true" do
      notification.variation = "mention"
      notification.mention?.should be true
    end
  end

  context "when notification type is not a mention" do
    it "returns false" do
      notification.variation = "not mention"
      notification.mention?.should be false
    end
  end

end
