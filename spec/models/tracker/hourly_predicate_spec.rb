require 'spec_helper'

describe Tracker, '#hourly?' do

  let(:tracker) { Tracker.new }

  context 'when the name is Hourly' do
    it 'returns true' do
      tracker.name = 'Hourly'
      tracker.hourly?.should be true
    end
  end

  context 'when the name is not Hourly' do
    it 'returns true' do
      tracker.name = 'not_hourly'
      tracker.hourly?.should be false
    end
  end

end
