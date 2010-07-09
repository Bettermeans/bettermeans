#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the ActivityStreamPreferencesControllerTest
require File.dirname(__FILE__) + '/../test_helper'
class ActivityStreamPreferencesControllerTest < ActionController::TestCase

  def test_should_get_index
    login_as :aaron
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_stream_preferences)
  end

  def test_should_fail_public_get_index
    get :index
    assert_redirected_to new_session_path
  end

  def test_all_checked_should_save_no_data
    login_as :aaron

    locations = []
    ACTIVITY_STREAM_ACTIVITIES.each_key do |key|
      [:public_location, :logged_in_location, :feed_location].each do |location|
        locations << "#{key}.#{location}"
      end
    end

    post :create, :<%= user_model_id %> => <%= user_model_table %>(:aaron).id, :locations => locations
    assert_equal(0, ActivityStreamPreference.find(:all, :conditions => { :<%= user_model_id %> => <%= user_model_table %>(:aaron)}).size)
  end

  def test_none_checked_should_save_all_data
    login_as :aaron
    post :create, :<%= user_model_id %> => <%= user_model_table %>(:aaron).id 
    assert_equal(18, ActivityStreamPreference.find(:all, :conditions => 
      { :<%= user_model_id %> => <%= user_model_table %>(:aaron)}).size)
  end

  def test_view_should_contain_atom_url
    login_as :aaron
    get :index

    a = "http://test.host/feeds/your_activities/#{<%= user_model_table %>(:aaron).activity_stream_token}"

    assert_match(/.*<a href="#{a}">#{a}<\/a>.*/m, @response.body)
  end

end
