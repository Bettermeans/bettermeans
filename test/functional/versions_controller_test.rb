# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'
require 'versions_controller'

# Re-raise errors caught by the controller.
class VersionsController; def rescue_action(e) raise e end; end

class VersionsControllerTest < ActionController::TestCase
  fixtures :projects, :versions, :issues, :users, :roles, :members, :member_roles, :enabled_modules
  
  def setup
    @controller = VersionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_show
    get :show, :id => 2
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:version)
    
    assert_tag :tag => 'h2', :content => /1.0/
  end
  
  def test_get_edit
    @request.session[:user_id] = 2
    get :edit, :id => 2
    assert_response :success
    assert_template 'edit'
  end
  
  def test_close_completed
    Version.update_all("status = 'open'")
    @request.session[:user_id] = 2
    post :close_completed, :project_id => 'ecookbook'
    assert_redirected_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => 'ecookbook'
    assert_not_nil Version.find_by_status('closed')
  end
  
  def test_post_edit
    @request.session[:user_id] = 2
    post :edit, :id => 2, 
                :version => { :name => 'New version name', 
                              :effective_date => Date.today.strftime("%Y-%m-%d")}
    assert_redirected_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => 'ecookbook'
    version = Version.find(2)
    assert_equal 'New version name', version.name
    assert_equal Date.today, version.effective_date
  end

  def test_destroy
    @request.session[:user_id] = 2
    post :destroy, :id => 3
    assert_redirected_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => 'ecookbook'
    assert_nil Version.find_by_id(3)
  end
  
  def test_issue_status_by
    xhr :get, :status_by, :id => 2
    assert_response :success
    assert_template '_issue_counts'
  end
end
