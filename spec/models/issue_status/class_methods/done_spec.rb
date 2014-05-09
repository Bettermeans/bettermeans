require 'spec_helper'

describe IssueStatus, '.done' do

  it 'returns the first instance with name "Done"' do
    IssueStatus.done.name.should == 'Done'
  end

end
