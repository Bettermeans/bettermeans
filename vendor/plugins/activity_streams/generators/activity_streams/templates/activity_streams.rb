#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# ActivityStreams configuration/initilization

# NOTE: The activites keys must be unique
ACTIVITY_STREAM_ACTIVITIES = { 
    :follow_creator => 'Subscribe or Unsubscribe to a Content Creator',
    :follow_category => 'Subscribe or Unsubscribe to a Category',
    :sponsor_creator => 'Sponsor a Content Creator',
    :posted_torrent => 'Upload a new torrent',
    :posted_message => 'Post a public message',
    :download => 'Download a torrent'}

# NOTE: These have hard coded meanings
ACTIVITY_STREAM_LOCATIONS = { 
    :public_location => 'Public Portion of of this site',
    :logged_in_location => 'Logged In Portion of this site',
    :feed_location => 'Your Activity Stream Atom Feed' }

ACTIVITY_STREAM_SERVICE_STRING="MyServiceName"
ACTIVITY_STREAM_USER_MODEL='<%= user_model %>'
ACTIVITY_STREAM_USER_MODEL_ID='<%= user_model_id %>'
ACTIVITY_STREAM_USER_MODEL_NAME='friendly_name'
