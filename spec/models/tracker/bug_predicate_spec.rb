require 'spec_helper'

describe Tracker, '#bug?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Bug' do
    it 'returns true' do
      tracker.name = 'Bug'
      tracker.bug?.should be true
    end
  end

  context 'when the name is not Bug' do
    it 'returns false' do
      tracker.name = 'not_bug'
      tracker.bug?.should be false
    end
  end

end
