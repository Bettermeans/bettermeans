require 'spec_helper'

describe Issue, '#hourly?' do

  let(:issue) { Issue.new }

  context 'when the tracker is hourly' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:hourly? => true))
      issue.hourly?.should be true
    end
  end

  context 'when the tracker is not hourly' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:hourly? => false))
      issue.hourly?.should be false
    end
  end

end
