# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'
require 'welcome_controller'

# Re-raise errors caught by the controller.
class WelcomeController; def rescue_action(e) raise e end; end

class WelcomeControllerTest < ActionController::TestCase
  fixtures :projects, :news
  
  def setup
    @controller = WelcomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:news)
    assert_not_nil assigns(:projects)
    assert !assigns(:projects).include?(Project.find(:first, :conditions => {:is_public => false}))
  end
  
  def test_browser_language
    Setting.default_language = 'en'
    @request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr,fr-fr;q=0.8,en-us;q=0.5,en;q=0.3'
    get :index
    assert_equal :fr, @controller.current_language
  end
  
  def test_browser_language_alternate
    Setting.default_language = 'en'
    @request.env['HTTP_ACCEPT_LANGUAGE'] = 'zh-TW'
    get :index
    assert_equal :"zh-TW", @controller.current_language
  end
  
  def test_browser_language_alternate_not_valid
    Setting.default_language = 'en'
    @request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr-CA'
    get :index
    assert_equal :fr, @controller.current_language
  end
  
  def test_robots
    get :robots
    assert_response :success
    assert_equal 'text/plain', @response.content_type
    assert @response.body.match(%r{^Disallow: /projects/ecookbook/issues$})
  end
end
