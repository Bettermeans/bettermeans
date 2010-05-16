require 'test_helper'

class ReputationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reputations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reputation" do
    assert_difference('Reputation.count') do
      post :create, :reputation => { }
    end

    assert_redirected_to reputation_path(assigns(:reputation))
  end

  test "should show reputation" do
    get :show, :id => reputations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => reputations(:one).to_param
    assert_response :success
  end

  test "should update reputation" do
    put :update, :id => reputations(:one).to_param, :reputation => { }
    assert_redirected_to reputation_path(assigns(:reputation))
  end

  test "should destroy reputation" do
    assert_difference('Reputation.count', -1) do
      delete :destroy, :id => reputations(:one).to_param
    end

    assert_redirected_to reputations_path
  end
end
