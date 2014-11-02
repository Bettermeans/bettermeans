require 'spec_helper'

describe Issue, '#duration' do

  let(:issue) { Factory.create(:issue) }

  it 'returns the difference when start_date and due_date are present' do
    issue.update_attributes!({
      :start_date => Date.current,
      :due_date => Date.current + 7,
    })
    issue.duration.should == 7
  end

  it 'returns 0 when start_date is not present' do
    issue.update_attributes!(:due_date => Date.current + 7)
    issue.duration.should == 0
  end

  it 'returns 0 when due_date is not present' do
    issue.update_attributes!(:start_date => Date.current)
    issue.duration.should == 0
  end

end
