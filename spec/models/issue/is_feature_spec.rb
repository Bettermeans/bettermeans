require 'spec_helper'

describe Issue, '#is_feature' do

  let(:issue) { Issue.new }

  context 'when tracker is feature' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:feature? => true))
      issue.is_feature.should be_true
    end
  end

  context 'when tracker is not feature' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:feature? => false))
      issue.is_feature.should be_false
    end
  end
end
