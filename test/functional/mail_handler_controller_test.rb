# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'
require 'mail_handler_controller'

# Re-raise errors caught by the controller.
class MailHandlerController; def rescue_action(e) raise e end; end

class MailHandlerControllerTest < ActionController::TestCase
  fixtures :users, :projects, :enabled_modules, :roles, :members, :member_roles, :issues, :issue_statuses, :trackers, :enumerations

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/mail_handler'

  def setup
    @controller = MailHandlerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml'))
    assert_response 201
  end

  def test_should_not_allow
    # Disable API
    Setting.mail_handler_api_enabled = 0
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml'))
    assert_response 403
  end
end
