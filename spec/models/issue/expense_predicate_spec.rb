require 'spec_helper'

describe Issue, '#expense?' do

  let(:issue) { Issue.new }

  context 'when the tracker is an expense' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:expense? => true))
      issue.expense?.should be true
    end
  end

  context 'when the tracker is not an expense' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:expense? => false))
      issue.expense?.should be false
    end
  end

end
