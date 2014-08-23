require 'spec_helper'

describe Credit, '#issue_day' do

  let(:credit) { Credit.new(:amount => 100) }

  it "returns a string for date it was issued on" do
    time = Time.now
    credit.issued_on = time
    credit.issue_day.should == time.strftime('%D')
  end

end
