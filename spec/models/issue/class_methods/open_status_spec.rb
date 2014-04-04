require 'spec_helper'

describe Issue, '.open_status' do

  let(:open_status) { IssueStatus.open }
  let(:done_status) { IssueStatus.done }

  it 'returns all issues where the status is open' do
    open_issue = Factory.create(:issue, :status => open_status)
    done_issue = Factory.create(:issue, :status => done_status)
    Issue.open_status.should == [open_issue]
  end

end
