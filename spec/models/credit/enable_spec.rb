require 'spec_helper'

describe Credit, '#enable' do

  let(:credit) { Credit.new(:amount => 100) }

  it "sets enabled status to true" do
    credit.enabled = false
    credit.enable
    credit.enabled.should == true
  end

  it 'returns the result of the save' do
    credit.stub(:save).and_return(true)
    credit.enable.should == true
  end

end
