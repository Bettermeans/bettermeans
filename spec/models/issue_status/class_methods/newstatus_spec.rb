require 'spec_helper'

describe IssueStatus, '.newstatus' do

  it 'returns the first instance with name "New"' do
    IssueStatus.newstatus.name.should == 'New'
  end

end
