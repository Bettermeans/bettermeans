Factory.define(:activity_stream_preference) do |factory|
  factory.activity { ACTIVITY_STREAM_ACTIVITIES.keys.sample.to_s }
  factory.location { ACTIVITY_STREAM_LOCATIONS.keys.sample.to_s }
end
