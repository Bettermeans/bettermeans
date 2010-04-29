require 'test_helper'

class MotionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:motions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create motion" do
    assert_difference('Motion.count') do
      post :create, :motion => { }
    end

    assert_redirected_to motion_path(assigns(:motion))
  end

  test "should show motion" do
    get :show, :id => motions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => motions(:one).to_param
    assert_response :success
  end

  test "should update motion" do
    put :update, :id => motions(:one).to_param, :motion => { }
    assert_redirected_to motion_path(assigns(:motion))
  end

  test "should destroy motion" do
    assert_difference('Motion.count', -1) do
      delete :destroy, :id => motions(:one).to_param
    end

    assert_redirected_to motions_path
  end
end
