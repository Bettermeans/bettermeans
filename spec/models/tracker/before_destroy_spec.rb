require 'spec_helper'

describe Tracker, 'before destroy' do

  let(:tracker) { Factory.create(:tracker) }
  let!(:issue) { Factory.create(:issue, :tracker => tracker) }

  it 'raises an error if there are any issues associated with the tracker' do
    expect {
      tracker.destroy
    }.to raise_error("Can't delete tracker")
  end

end
