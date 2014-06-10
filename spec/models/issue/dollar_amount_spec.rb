require 'spec_helper'

describe Issue, '#dollar_amount' do

  let(:issue) { Issue.new }

  it 'return points' do
    issue.points = 10
    issue.dollar_amount.should == 10
  end

end
