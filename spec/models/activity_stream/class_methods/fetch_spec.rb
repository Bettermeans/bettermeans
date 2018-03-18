require 'spec_helper'

describe ActivityStream, '.fetch' do

  it 'returns an empty collection when there are no streams' do
    ActivityStream.fetch(1, nil, true, nil).should eql []
  end

  it 'returns streams created before max_created_at' do
    ActivityStream.create!(:is_public => true)
    old_stream = ActivityStream.create!(
      :created_at => 5.years.ago,
      :is_public => true
    )

    streams = ActivityStream.fetch(nil, nil, true, nil, 1.year.ago)
    streams.should eql [['', [old_stream]]]
  end

end
