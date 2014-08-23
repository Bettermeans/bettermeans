require 'spec_helper'

describe Tracker, '#recurring?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Recurring' do
    it 'returns true' do
      tracker.name = 'Recurring'
      tracker.recurring?.should be true
    end
  end

  context 'when the name is not Recurring' do
    it 'returns false' do
      tracker.name = 'not_recurring'
      tracker.recurring?.should be false
    end
  end

end
