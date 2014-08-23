require 'spec_helper'

describe Journal, '#update_issue_timestamp' do

  it 'updates timestamp for journal.issue' do
    time = Time.now
    DateTime.stub(:now).and_return(time)
    issue = Issue.new
    issue.should_receive(:save)
    journal = Journal.new(:issue => issue)
    journal.update_issue_timestamp
    issue.updated_at.should == time
  end

end
