require 'test_helper'

class PrisControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pris)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pri" do
    assert_difference('Pri.count') do
      post :create, :pri => { }
    end

    assert_redirected_to pri_path(assigns(:pri))
  end

  test "should show pri" do
    get :show, :id => pris(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pris(:one).to_param
    assert_response :success
  end

  test "should update pri" do
    put :update, :id => pris(:one).to_param, :pri => { }
    assert_redirected_to pri_path(assigns(:pri))
  end

  test "should destroy pri" do
    assert_difference('Pri.count', -1) do
      delete :destroy, :id => pris(:one).to_param
    end

    assert_redirected_to pris_path
  end
end
