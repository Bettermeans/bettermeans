require 'spec_helper'

describe Issue, '#is_bug' do

  let(:issue) { Issue.new }

  context 'when tracker is bug' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:bug? => true))
      issue.is_bug.should be true
    end
  end

  context 'when tracker is not bug' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:bug? => false))
      issue.is_bug.should be false
    end
  end

end
