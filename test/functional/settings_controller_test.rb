# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'
require 'settings_controller'

# Re-raise errors caught by the controller.
class SettingsController; def rescue_action(e) raise e end; end

class SettingsControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'edit'
  end
  
  def test_get_edit
    get :edit
    assert_response :success
    assert_template 'edit'
  end
  
  def test_post_edit_notifications
    post :edit, :settings => {:mail_from => 'functional@test.foo',
                              :bcc_recipients  => '0',
                              :notified_events => %w(issue_added issue_updated news_added),
                              :emails_footer => 'Test footer'
                              }
    assert_redirected_to 'settings/edit'
    assert_equal 'functional@test.foo', Setting.mail_from
    assert !Setting.bcc_recipients?
    assert_equal %w(issue_added issue_updated news_added), Setting.notified_events
    assert_equal 'Test footer', Setting.emails_footer
  end
end
