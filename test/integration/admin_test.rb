# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

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
end
