require 'spec_helper'

describe IssueStatus, '.inprogress' do

  it 'returns the first instance with name "Committed"' do
    IssueStatus.inprogress.name.should == 'Committed'
  end

end
