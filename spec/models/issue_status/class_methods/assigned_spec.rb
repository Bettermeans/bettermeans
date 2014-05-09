require 'spec_helper'

describe IssueStatus, '.assigned' do

  it 'returns the first instance with name "Committed"' do
    IssueStatus.assigned.name.should == 'Committed'
  end

end
