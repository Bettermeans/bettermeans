#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Template to generate the ActivityStreamsControllerTest
require File.dirname(__FILE__) + '/../test_helper'
class ActivityStreamsControllerTest < ActionController::TestCase

  def test_public_should_get_feed
    get :feed, :activity_stream_token => <%= user_model_table %>(:aaron).activity_stream_token

    assert_tag  :tag => 'feed', :attributes => {'xmlns' => 'http://www.w3.org/2005/Atom'}
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_streams)
  end

  def test_should_fail_public_get_index
    get :index
    assert_redirected_to new_session_path
  end

  def test_should_fail_not_admin_get_index
    login_as :aaron
    get :index
    assert_redirected_to '/'
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_should_fail_public_get_new
    get :new
    assert_redirected_to new_session_path
  end

  def test_should_fail_not_admin_get_index
    login_as :aaron
    get :new
    assert_redirected_to '/'
  end

  def test_should_create_activity_stream
    login_as :admin
    assert_difference('ActivityStream.count') do
      post :create, :activity_stream => { }
    end

    assert_redirected_to activity_stream_path(assigns(:activity_stream))
  end

  def test_should_fail_public_create_activity_stream
    assert_no_difference('ActivityStream.count') do
      post :create, :activity_stream => { }
    end

    assert_redirected_to new_session_path
  end

  def test_should_fail_not_adminc_create_activity_stream
    login_as :aaron
    assert_no_difference('ActivityStream.count') do
      post :create, :activity_stream => { }
    end

    assert_redirected_to '/'
  end

  def test_should_show_activity_stream
    login_as :admin
    get :show, :id => activity_streams(:one).id
    assert_response :success
  end

  def test_should_fail_public_show_activity_stream
    get :show, :id => activity_streams(:one).id
    assert_redirected_to new_session_path
  end

  def test_should_fail_not_admin_show_activity_stream
    login_as :aaron
    get :show, :id => activity_streams(:one).id
    assert_redirected_to '/'
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => activity_streams(:one).id
    assert_response :success
  end

  def test_should_fail_pubic_get_edit
    get :edit, :id => activity_streams(:one).id
    assert_redirected_to new_session_path
  end

  def test_should_fail_not_admin_get_edit
    login_as :aaron
    get :edit, :id => activity_streams(:one).id
    assert_redirected_to '/'
  end

  def test_should_update_activity_stream
    login_as :admin
    put :update, :id => activity_streams(:one).id, :activity_stream => { }
    assert_redirected_to activity_stream_path(assigns(:activity_stream))
  end

  def test_should_fail_public_update_activity_stream
    put :update, :id => activity_streams(:one).id, :activity_stream => { }
    assert_redirected_to new_session_path
  end

  def test_should_fail_not_admin_update_activity_stream
    login_as :aaron
    put :update, :id => activity_streams(:one).id, :activity_stream => { }
    assert_redirected_to '/'
  end

  def test_should_destroy_activity_stream
    login_as :admin

    delete :destroy, :id => activity_streams(:one).id, :ref => <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))

    as = ActivityStream.find(activity_streams(:one).id)
    assert_equal(ActivityStream::DELETED, as.status)

    assert_redirected_to <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))
  end

  def test_should_destroy_activity_stream_if_owner
    login_as :aaron

    delete :destroy, :id => activity_streams(:one).id, :ref => <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))

    as = ActivityStream.find(activity_streams(:one).id)
    assert_equal(ActivityStream::DELETED, as.status)

    assert_redirected_to <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))
  end

  def test_should_fail_public_destroy_activity_stream
    assert_no_difference('ActivityStream.count') do
      delete :destroy, :id => activity_streams(:one).id
    end

    assert_redirected_to new_session_path
  end

  def test_should_fail_not_owner_destroy_activity_stream
    login_as :fred

    delete :destroy, :id => activity_streams(:one).id, :ref => <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))

    as = ActivityStream.find(activity_streams(:one).id)
    assert_equal(ActivityStream::VISIBLE, as.status)

    assert_redirected_to <%= user_model.underscore %>_path(<%= user_model_table %>(:aaron))
  end

end
