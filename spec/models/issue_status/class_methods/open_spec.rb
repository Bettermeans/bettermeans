require 'spec_helper'

describe IssueStatus, '.open' do

  it 'returns the first instance with name "Open"' do
    IssueStatus.open.name.should == 'Open'
  end

end
