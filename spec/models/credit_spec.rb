require "spec_helper"

describe Credit do

  describe "#enable" do
    let(:credit) { Credit.new }

    it "sets enabled status to true" do
      credit.amount = 100
      credit.enabled = false
      credit.enable
      credit.enabled.should == true
    end
  end

  describe "#disable" do
    let(:credit) { Credit.new }

    it "sets enabled status to false" do
      credit.amount = 100
      credit.enabled = true
      credit.disable
      credit.enabled.should == false
    end
  end
end
