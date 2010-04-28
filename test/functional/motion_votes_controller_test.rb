require 'test_helper'

class MotionVotesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:motion_votes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create motion_vote" do
    assert_difference('MotionVote.count') do
      post :create, :motion_vote => { }
    end

    assert_redirected_to motion_vote_path(assigns(:motion_vote))
  end

  test "should show motion_vote" do
    get :show, :id => motion_votes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => motion_votes(:one).to_param
    assert_response :success
  end

  test "should update motion_vote" do
    put :update, :id => motion_votes(:one).to_param, :motion_vote => { }
    assert_redirected_to motion_vote_path(assigns(:motion_vote))
  end

  test "should destroy motion_vote" do
    assert_difference('MotionVote.count', -1) do
      delete :destroy, :id => motion_votes(:one).to_param
    end

    assert_redirected_to motion_votes_path
  end
end
