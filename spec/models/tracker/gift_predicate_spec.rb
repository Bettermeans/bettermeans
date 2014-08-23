require 'spec_helper'

describe Tracker, '#gift?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Gift' do
    it 'returns true' do
      tracker.name = 'Gift'
      tracker.gift?.should be true
    end
  end

  context 'when the name is not Gift' do
    it 'returns false' do
      tracker.name = 'not_gift'
      tracker.gift?.should be false
    end
  end

end
