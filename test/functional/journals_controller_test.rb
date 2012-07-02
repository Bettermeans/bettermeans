# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'
require 'journals_controller'

# Re-raise errors caught by the controller.
class JournalsController; def rescue_action(e) raise e end; end

class JournalsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals, :journal_details, :enabled_modules

  def setup
    @controller = JournalsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_get_edit
    @request.session[:user_id] = 1
    xhr :get, :edit, :id => 2
    assert_response :success
    assert_select_rjs :insert, :after, 'journal-2-notes' do
      assert_select 'form[id=journal-2-form]'
      assert_select 'textarea'
    end
  end

  def test_post_edit
    @request.session[:user_id] = 1
    xhr :post, :edit, :id => 2, :notes => 'Updated notes'
    assert_response :success
    assert_select_rjs :replace, 'journal-2-notes'
    assert_equal 'Updated notes', Journal.find(2).notes
  end

  def test_post_edit_with_empty_notes
    @request.session[:user_id] = 1
    xhr :post, :edit, :id => 2, :notes => ''
    assert_response :success
    assert_select_rjs :remove, 'change-2'
    assert_nil Journal.find_by_id(2)
  end
end
