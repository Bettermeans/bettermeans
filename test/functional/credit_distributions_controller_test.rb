require 'test_helper'

class CreditDistributionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:credit_distributions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create credit_distribution" do
    assert_difference('CreditDistribution.count') do
      post :create, :credit_distribution => { }
    end

    assert_redirected_to credit_distribution_path(assigns(:credit_distribution))
  end

  test "should show credit_distribution" do
    get :show, :id => credit_distributions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => credit_distributions(:one).to_param
    assert_response :success
  end

  test "should update credit_distribution" do
    put :update, :id => credit_distributions(:one).to_param, :credit_distribution => { }
    assert_redirected_to credit_distribution_path(assigns(:credit_distribution))
  end

  test "should destroy credit_distribution" do
    assert_difference('CreditDistribution.count', -1) do
      delete :destroy, :id => credit_distributions(:one).to_param
    end

    assert_redirected_to credit_distributions_path
  end
end
