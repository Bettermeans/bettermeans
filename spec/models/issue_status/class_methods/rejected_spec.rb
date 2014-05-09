require 'spec_helper'

describe IssueStatus, '.rejected' do

  it 'returns the first instance with name "Rejected"' do
    IssueStatus.rejected.name.should == 'Rejected'
  end

end
