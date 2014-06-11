require 'spec_helper'

describe Issue, '#bug?' do

  let(:issue) { Issue.new }

  context 'when tracker is bug' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:bug? => true))
      issue.bug?.should be true
    end
  end

  context 'when tracker is not bug' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:bug? => false))
      issue.bug?.should be false
    end
  end

end
