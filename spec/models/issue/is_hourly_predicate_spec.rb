require 'spec_helper'

describe Issue, '#is_hourly?' do

  let(:issue) { Issue.new }

  context 'when the tracker is hourly' do
    it 'returns true' do
      issue.stub(:tracker).and_return(mock(:hourly? => true))
      issue.is_hourly?.should be_true
    end
  end

  context 'when the tracker is not hourly' do
    it 'returns false' do
      issue.stub(:tracker).and_return(mock(:hourly? => false))
      issue.is_hourly?.should be_false
    end
  end

end
