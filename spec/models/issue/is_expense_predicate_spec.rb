require 'spec_helper'

describe Issue, '#is_expense?' do

  let(:issue) { Issue.new }

  context 'when the tracker is an expense' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:expense? => true))
      issue.is_expense?.should be true
    end
  end

  context 'when the tracker is not an expense' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:expense? => false))
      issue.is_expense?.should be false
    end
  end

end
