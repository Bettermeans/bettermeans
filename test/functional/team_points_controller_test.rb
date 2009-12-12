require 'test_helper'

class TeamPointsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:team_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create team_point" do
    assert_difference('TeamPoint.count') do
      post :create, :team_point => { }
    end

    assert_redirected_to team_point_path(assigns(:team_point))
  end

  test "should show team_point" do
    get :show, :id => team_points(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => team_points(:one).to_param
    assert_response :success
  end

  test "should update team_point" do
    put :update, :id => team_points(:one).to_param, :team_point => { }
    assert_redirected_to team_point_path(assigns(:team_point))
  end

  test "should destroy team_point" do
    assert_difference('TeamPoint.count', -1) do
      delete :destroy, :id => team_points(:one).to_param
    end

    assert_redirected_to team_points_path
  end
end
