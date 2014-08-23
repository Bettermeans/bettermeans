require 'spec_helper'

describe Tracker, '#chore?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Chore' do
    it 'returns true' do
      tracker.name = 'Chore'
      tracker.chore?.should be true
    end
  end

  context 'when the name is not Chore' do
    it 'returns false' do
      tracker.name = 'not_chore'
      tracker.chore?.should be false
    end
  end

end
