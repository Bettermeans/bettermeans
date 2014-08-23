require 'spec_helper'

describe Tracker, '#feature?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Feature' do
    it 'returns true' do
      tracker.name = 'Feature'
      tracker.feature?.should be true
    end
  end

  context 'when the name is not Feature' do
    it 'returns false' do
      tracker.name = 'not_feature'
      tracker.feature?.should be false
    end
  end

end
