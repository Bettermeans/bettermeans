# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.

# activity_stream_preference.rb provides the model ActivityStreamPreference
#
# ActivityStreamPreference is the model used to keep track of preferences for the Activity Stream Plug-in

class ActivityStreamPreference < ActiveRecord::Base
end

# == Schema Information
#
# Table name: activity_stream_preferences
#
#  id         :integer         not null, primary key
#  activity   :string(255)
#  location   :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

