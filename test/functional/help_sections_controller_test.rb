require 'test_helper'

class HelpSectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:help_sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create help_section" do
    assert_difference('HelpSection.count') do
      post :create, :help_section => { }
    end

    assert_redirected_to help_section_path(assigns(:help_section))
  end

  test "should show help_section" do
    get :show, :id => help_sections(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => help_sections(:one).to_param
    assert_response :success
  end

  test "should update help_section" do
    put :update, :id => help_sections(:one).to_param, :help_section => { }
    assert_redirected_to help_section_path(assigns(:help_section))
  end

  test "should destroy help_section" do
    assert_difference('HelpSection.count', -1) do
      delete :destroy, :id => help_sections(:one).to_param
    end

    assert_redirected_to help_sections_path
  end
end
