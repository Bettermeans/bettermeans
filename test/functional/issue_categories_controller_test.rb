# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'
require 'issue_categories_controller'

# Re-raise errors caught by the controller.
class IssueCategoriesController; def rescue_action(e) raise e end; end

class IssueCategoriesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules, :issue_categories
  
  def setup
    @controller = IssueCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2
  end
  
  def test_post_edit
    assert_no_difference 'IssueCategory.count' do
      post :edit, :id => 2, :category => { :name => 'Testing' }
    end
    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_equal 'Testing', IssueCategory.find(2).name
  end
  
  def test_edit_not_found
    post :edit, :id => 97, :category => { :name => 'Testing' }
    assert_response 404
  end
  
  def test_destroy_category_not_in_use
    post :destroy, :id => 2
    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_nil IssueCategory.find_by_id(2)
  end
  
  def test_destroy_category_in_use
    post :destroy, :id => 1
    assert_response :success
    assert_template 'destroy'
    assert_not_nil IssueCategory.find_by_id(1)
  end
  
  def test_destroy_category_in_use_with_reassignment
    issue = Issue.find(:first, :conditions => {:category_id => 1})
    post :destroy, :id => 1, :todo => 'reassign', :reassign_to_id => 2
    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_nil IssueCategory.find_by_id(1)
    # check that the issue was reassign
    assert_equal 2, issue.reload.category_id
  end
  
  def test_destroy_category_in_use_without_reassignment
    issue = Issue.find(:first, :conditions => {:category_id => 1})
    post :destroy, :id => 1, :todo => 'nullify'
    assert_redirected_to '/projects/ecookbook/settings/categories'
    assert_nil IssueCategory.find_by_id(1)
    # check that the issue category was nullified
    assert_nil issue.reload.category_id
  end
end
