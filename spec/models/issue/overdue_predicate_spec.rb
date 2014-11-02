require 'spec_helper'

describe Issue, '#overdue?' do

  let(:status) { Factory.create(:issue_status) }
  let(:issue) do
    Factory.create(:issue, :due_date => 1.month.ago, :status => status)
  end

  it 'returns false when there is no due date' do
    issue.update_attributes!(:due_date => nil)
    issue.overdue?.should be false
  end

  it 'returns false when the status is closed' do
    status.update_attributes!(:is_closed => true)
    issue.overdue?.should be false
  end

  it 'returns false when the due date >= now' do
    issue.update_attributes!(:due_date => 1.month.from_now)
    issue.overdue?.should be false
  end

  it 'returns true when due date is in past and status is open' do
    issue.overdue?.should be true
  end

end
