require 'test_helper'

class EnterprisesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:enterprises)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create enterprise" do
    assert_difference('Enterprise.count') do
      post :create, :enterprise => { }
    end

    assert_redirected_to enterprise_path(assigns(:enterprise))
  end

  test "should show enterprise" do
    get :show, :id => enterprises(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => enterprises(:one).to_param
    assert_response :success
  end

  test "should update enterprise" do
    put :update, :id => enterprises(:one).to_param, :enterprise => { }
    assert_redirected_to enterprise_path(assigns(:enterprise))
  end

  test "should destroy enterprise" do
    assert_difference('Enterprise.count', -1) do
      delete :destroy, :id => enterprises(:one).to_param
    end

    assert_redirected_to enterprises_path
  end
end
