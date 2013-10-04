require 'spec_helper'

describe Issue do

  let(:issue) { Issue.new }

  describe '#is_gift?' do
    context 'when the tracker is a gift' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:gift? => true))
        issue.is_gift?.should be_true
      end
    end

    context 'when the tracker is not a gift' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:gift? => false))
        issue.is_gift?.should be_false
      end
    end
  end

  describe '#is_expense?' do
    context 'when the tracker is an expense' do
      it 'returns true' do
        issue.stub(:tracker).and_return(mock(:expense? => true))
        issue.is_expense?.should be_true
      end
    end

    context 'when the tracker is not an expense' do
      it 'returns false' do
        issue.stub(:tracker).and_return(mock(:expense? => false))
        issue.is_expense?.should be_false
      end
    end
  end

end
