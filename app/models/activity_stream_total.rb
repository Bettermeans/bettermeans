# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.

# activity_stream_total.rb provides the model ActivityStreamTotal
#
# ActivityStreamTotal is the model used to keep total counts on related activities
#

class ActivityStreamTotal < ActiveRecord::Base
  belongs_to :object, :polymorphic => true
end

# == Schema Information
#
# Table name: activity_stream_totals
#
#  id          :integer         not null, primary key
#  activity    :string(255)
#  object_id   :integer
#  object_type :string(255)
#  total       :float           default(0.0)
#  created_at  :datetime
#  updated_at  :datetime
#

