require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invitations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invitation" do
    assert_difference('Invitation.count') do
      post :create, :invitation => { }
    end

    assert_redirected_to invitation_path(assigns(:invitation))
  end

  test "should show invitation" do
    get :show, :id => invitations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => invitations(:one).to_param
    assert_response :success
  end

  test "should update invitation" do
    put :update, :id => invitations(:one).to_param, :invitation => { }
    assert_redirected_to invitation_path(assigns(:invitation))
  end

  test "should destroy invitation" do
    assert_difference('Invitation.count', -1) do
      delete :destroy, :id => invitations(:one).to_param
    end

    assert_redirected_to invitations_path
  end
end
