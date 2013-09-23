# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.

# activity_stream_preference.rb provides the model ActivityStreamPreference
#
# ActivityStreamPreference is the model used to keep track of preferences for the Activity Stream Plug-in

class ActivityStreamPreference < ActiveRecord::Base

  def self.location_keys # spec_me cover_me heckle_me
    all_locations = []
    ACTIVITY_STREAM_LOCATIONS.each do |location|
      ACTIVITY_STREAM_ACTIVITIES.each_key do |activity|
        all_locations << "#{activity.to_s}.#{location[0]}"
      end
    end
    all_locations
  end

  def location_key # spec_me cover_me heckle_me
    "#{activity.to_s}.#{location.to_s}"
  end
end
