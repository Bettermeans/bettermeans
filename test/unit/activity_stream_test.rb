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
    activity_streams = ActivityStream.recent_actors(users(:aaron),
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
    activity_stream.actor_type= 'User'
    activity_stream.object_id= '2'
    activity_stream.object_type= 'User'
    activity_stream.verb= 'is_friends_with'
    activity_stream.activity= 'friends'
    activity_stream.object_name_method= 'friendly_name'
    activity_stream.actor_name_method= 'friendly_name'
    activity_stream.status= 0
    activity_stream.save!

    as = ActivityStream.find_identical(User.find(1), User.find(2),
      :is_friends_with, :friends)

    assert_equal as, activity_stream

  end

  def test_find_identical_finds_nothing
    activity_stream = ActivityStream.new
    activity_stream.actor_id = 1
    activity_stream.actor_type= 'User'
    activity_stream.object_id= '2'
    activity_stream.object_type= 'User'
    activity_stream.verb= 'is_friends_with'
    activity_stream.activity= 'friends'
    activity_stream.object_name_method= 'friendly_name'
    activity_stream.actor_name_method= 'friendly_name'
    activity_stream.status= 0
    activity_stream.save!

    as = ActivityStream.find_identical(User.find(1), User.find(2),
      :is_no_longer_friends_with, :friends)

    assert_nil as
  end

end




# == Schema Information
#
# Table name: activity_streams
#
#  id                          :integer         not null, primary key
#  verb                        :string(255)
#  activity                    :string(255)
#  actor_id                    :integer
#  actor_type                  :string(255)
#  actor_name_method           :string(255)
#  count                       :integer         default(1)
#  object_id                   :integer
#  object_type                 :string(255)
#  object_name_method          :string(255)
#  indirect_object_id          :integer
#  indirect_object_type        :string(255)
#  indirect_object_name_method :string(255)
#  indirect_object_phrase      :string(255)
#  status                      :integer         default(0)
#  created_at                  :datetime
#  updated_at                  :datetime
#  project_id                  :integer         default(0)
#  actor_name                  :string(255)
#  object_name                 :string(255)
#  object_description          :text
#  indirect_object_name        :string(255)
#  indirect_object_description :text
#  tracker_name                :string(255)
#  project_name                :string(255)
#  actor_email                 :string(255)
#  is_public                   :boolean         default(FALSE)
#  hidden_from_user_id         :integer         default(0)
#

