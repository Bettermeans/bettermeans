require "spec_helper"

describe Credit do

  describe "#issue_day" do
    let(:credit) { Credit.new }

    it "returns a string for date it was issued on" do
      time = Time.now
      credit.issued_on = time
      credit.issue_day.should == time.strftime('%D')
    end
  end

  describe "#enable" do
    let(:credit) { Credit.new }

    it "sets enabled status to true" do
      credit.amount = 100
      credit.enabled = false
      credit.enable
      credit.enabled.should == true
    end

    it 'returns the result of the save' do
      credit.stub(:save).and_return(true)
      credit.enable.should == true
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
