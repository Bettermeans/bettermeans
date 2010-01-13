require 'test_helper'

class IssueVotesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:issue_votes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create issue_vote" do
    assert_difference('IssueVote.count') do
      post :create, :issue_vote => { }
    end

    assert_redirected_to issue_vote_path(assigns(:issue_vote))
  end

  test "should show issue_vote" do
    get :show, :id => issue_votes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => issue_votes(:one).to_param
    assert_response :success
  end

  test "should update issue_vote" do
    put :update, :id => issue_votes(:one).to_param, :issue_vote => { }
    assert_redirected_to issue_vote_path(assigns(:issue_vote))
  end

  test "should destroy issue_vote" do
    assert_difference('IssueVote.count', -1) do
      delete :destroy, :id => issue_votes(:one).to_param
    end

    assert_redirected_to issue_votes_path
  end
end
