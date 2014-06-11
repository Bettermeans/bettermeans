require 'spec_helper'

describe Issue, '#gift?' do

  let(:issue) { Issue.new }

  context 'when the tracker is a gift' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:gift? => true))
      issue.gift?.should be true
    end
  end

  context 'when the tracker is not a gift' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:gift? => false))
      issue.gift?.should be false
    end
  end

end
