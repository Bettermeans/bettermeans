#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the ActivityStream Unit Test
require File.dirname(__FILE__) + '/../test_helper'
class ActivityStreamTest < ActiveSupport::TestCase
  fixtures :activity_streams

  def test_soft_delete_changes_status
    activity_stream = activity_streams(:one)
    activity_stream.soft_destroy

    activity_stream.reload
    assert_equal activity_stream.status, ActivityStream::DELETED
  end

  def test_object_name
    activity_stream = activity_streams(:one)

    assert_equal activity_stream.object_name, 'test_torrent'
  end

  def test_actor_name
    activity_stream = activity_streams(:one)

    assert_equal activity_stream.actor_name, 'aaron'
  end

  # Note the integration test will test the interaction between 
  # activity_streams and activity_stream_preferences
  def test_recent_actors
    activity_streams = ActivityStream.recent_actors(<%= user_model_table %>(:aaron), 
      :public_location, 5)
    assert_equal 5, activity_streams.size
  end

  def test_recent_objects
    activity_streams = ActivityStream.recent_objects(torrents(:test_torrent), 
      :public_location, 5)
    assert_equal 5, activity_streams.size
  end

  def test_find_identical_finds_identical
    activity_stream = ActivityStream.new
    activity_stream.actor_id = 1
    activity_stream.actor_type= '<%= user_model %>'
    activity_stream.object_id= '2'
    activity_stream.object_type= '<%= user_model %>'
    activity_stream.verb= 'is_friends_with'
    activity_stream.activity= 'friends'
    activity_stream.object_name_method= 'friendly_name'
    activity_stream.actor_name_method= 'friendly_name'
    activity_stream.status= 0
    activity_stream.save!

    as = ActivityStream.find_identical(<%= user_model %>.find(1), <%= user_model %>.find(2),
      :is_friends_with, :friends)

    assert_equal as, activity_stream

  end

  def test_find_identical_finds_nothing
    activity_stream = ActivityStream.new
    activity_stream.actor_id = 1
    activity_stream.actor_type= '<%= user_model %>'
    activity_stream.object_id= '2'
    activity_stream.object_type= '<%= user_model %>'
    activity_stream.verb= 'is_friends_with'
    activity_stream.activity= 'friends'
    activity_stream.object_name_method= 'friendly_name'
    activity_stream.actor_name_method= 'friendly_name'
    activity_stream.status= 0
    activity_stream.save!

    as = ActivityStream.find_identical(<%= user_model %>.find(1), <%= user_model %>.find(2),
      :is_no_longer_friends_with, :friends)

    assert_nil as
  end

end
