require 'spec_helper'

describe Tracker, '#to_s' do

  let(:tracker) { Tracker.new }

  it 'returns stringified object' do
    tracker.name = 'pie'
    tracker.to_s.should == "pie"
  end

end
