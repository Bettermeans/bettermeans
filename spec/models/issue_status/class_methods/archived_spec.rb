require 'spec_helper'

describe IssueStatus, '.archived' do

  it 'returns the first instance with status "Archived"' do
    IssueStatus.archived.name.should == 'Archived'
  end

end
