require 'spec_helper'

describe Journal, '#issue_id' do

  let(:journal) { Journal.new }

  it 'returns journalized_id' do
    journal.journalized_id = 1
    journal.issue_id.should == 1
  end

end
