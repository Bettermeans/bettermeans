# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require "#{File.dirname(__FILE__)}/../test_helper"

class AdminTest < ActionController::IntegrationTest
  fixtures :all

  def test_add_user
    log_user("admin", "admin")
    get "/users/new"
    assert_response :success
    assert_template "users/add"
    post "/users/add", :user => { :login => "psmith", :firstname => "Paul", :lastname => "Smith", :mail => "psmith@somenet.food", :language => "en" }, :password => "psmith09", :password_confirmation => "psmith09"

    user = User.find_by_login("psmith")
    assert_kind_of User, user
    assert_redirected_to "/users/#{ user.id }/edit"

    logged_user = User.try_to_login("psmith", "psmith09")
    assert_kind_of User, logged_user
    assert_equal "Paul", logged_user.firstname

    post "users/edit", :id => user.id, :user => { :status => User::STATUS_LOCKED }
    assert_redirected_to "/users/#{ user.id }/edit"
    locked_user = User.try_to_login("psmith", "psmith09")
    assert_equal nil, locked_user
  end

  test "Add a user as an anonymous user should fail" do
    post '/users/add', :user => { :login => 'psmith', :firstname => 'Paul'}, :password => "psmith09", :password_confirmation => "psmith09"
    assert_response :redirect
    assert_redirected_to "/login?back_url=http%3A%2F%2Fwww.example.com%2Fusers%2Fnew"
  end
end
