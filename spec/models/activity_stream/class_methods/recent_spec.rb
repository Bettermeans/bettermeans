require 'spec_helper'

describe ActivityStream, '.recent' do

  it 'returns activity streams that were created recently' do
    stream1 = Factory.create(:activity_stream)
    stream2 = Factory.create(:activity_stream, :created_at => 1.month.ago)
    ActivityStream.recent.should == [stream1]
  end

end
