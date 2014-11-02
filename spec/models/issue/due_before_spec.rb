require 'spec_helper'

describe Issue, '#due_before' do

  let(:issue) { Factory.create(:issue) }

  it 'returns the due date' do
    date = Date.current + 1.week
    issue.update_attributes!(:due_date => date)
    issue.due_before.should == date
  end

end
