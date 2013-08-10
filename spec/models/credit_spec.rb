require "spec_helper"

describe Credit do

  describe "#enable" do
    let(:credit) { Credit.new }

    it "sets enabled status to true" do
      credit.amount = 100
      credit.enabled = false
      credit.enable
      credit.enabled == true
    end
  end

  describe "#disable" do
    let(:credit) { Credit.new }

    it "sets enabled status to false" do
      credit.amount = 100
      credit.enabled = true
      credit.disable
      credit.enabled == false
    end
  end
end
