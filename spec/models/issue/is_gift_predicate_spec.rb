require 'spec_helper'

describe Issue, '#is_gift?' do

  let(:issue) { Issue.new }

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
