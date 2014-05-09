require 'spec_helper'

describe IssueStatus, '.estimate' do

  it 'returns the first instance with name "Estimate"' do
    IssueStatus.estimate.name.should == 'Estimate'
  end

end
