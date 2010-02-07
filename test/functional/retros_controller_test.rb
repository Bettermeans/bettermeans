require 'test_helper'

class RetrosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:retros)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create retro" do
    assert_difference('Retro.count') do
      post :create, :retro => { }
    end

    assert_redirected_to retro_path(assigns(:retro))
  end

  test "should show retro" do
    get :show, :id => retros(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => retros(:one).to_param
    assert_response :success
  end

  test "should update retro" do
    put :update, :id => retros(:one).to_param, :retro => { }
    assert_redirected_to retro_path(assigns(:retro))
  end

  test "should destroy retro" do
    assert_difference('Retro.count', -1) do
      delete :destroy, :id => retros(:one).to_param
    end

    assert_redirected_to retros_path
  end
end
