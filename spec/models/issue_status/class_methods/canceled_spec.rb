require 'spec_helper'

describe IssueStatus, '.canceled' do

  it 'returns the first instance with name "Canceled"' do
    IssueStatus.canceled.name.should == 'Canceled'
  end

end
