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
