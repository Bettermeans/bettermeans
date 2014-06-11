require 'spec_helper'

describe Issue, '#is_chore' do

  let(:issue) { Issue.new }

  context 'when tracker is chore' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:chore? => true))
      issue.is_chore.should be true
    end
  end

  context 'when tracker is not chore' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:chore? => false))
      issue.is_chore.should be false
    end
  end

end
