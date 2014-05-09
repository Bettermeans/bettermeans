require 'spec_helper'

describe IssueStatus, '.accepted' do

  it 'returns the first instance with the name "Accepted"' do
    IssueStatus.accepted.name.should == 'Accepted'
  end

end
