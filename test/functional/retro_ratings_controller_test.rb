require 'test_helper'

class RetroRatingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:retro_ratings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create retro_rating" do
    assert_difference('RetroRating.count') do
      post :create, :retro_rating => { }
    end

    assert_redirected_to retro_rating_path(assigns(:retro_rating))
  end

  test "should show retro_rating" do
    get :show, :id => retro_ratings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => retro_ratings(:one).to_param
    assert_response :success
  end

  test "should update retro_rating" do
    put :update, :id => retro_ratings(:one).to_param, :retro_rating => { }
    assert_redirected_to retro_rating_path(assigns(:retro_rating))
  end

  test "should destroy retro_rating" do
    assert_difference('RetroRating.count', -1) do
      delete :destroy, :id => retro_ratings(:one).to_param
    end

    assert_redirected_to retro_ratings_path
  end
end
