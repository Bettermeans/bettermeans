require 'spec_helper'

describe Credit, '#disable' do

  let(:credit) { Credit.new(:amount => 100) }

  it "sets enabled status to false" do
    credit.enabled = true
    credit.disable
    credit.enabled.should == false
  end

  it 'returns the result of the save' do
    credit.stub(:save).and_return(false)
    credit.disable.should be false
  end

end
