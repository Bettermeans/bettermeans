require 'test_helper'

class TeamOffersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:team_offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create team_offer" do
    assert_difference('TeamOffer.count') do
      post :create, :team_offer => { }
    end

    assert_redirected_to team_offer_path(assigns(:team_offer))
  end

  test "should show team_offer" do
    get :show, :id => team_offers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => team_offers(:one).to_param
    assert_response :success
  end

  test "should update team_offer" do
    put :update, :id => team_offers(:one).to_param, :team_offer => { }
    assert_redirected_to team_offer_path(assigns(:team_offer))
  end

  test "should destroy team_offer" do
    assert_difference('TeamOffer.count', -1) do
      delete :destroy, :id => team_offers(:one).to_param
    end

    assert_redirected_to team_offers_path
  end
end
