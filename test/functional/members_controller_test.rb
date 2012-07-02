# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'
require 'members_controller'

# Re-raise errors caught by the controller.
class MembersController; def rescue_action(e) raise e end; end


class MembersControllerTest < ActionController::TestCase
  fixtures :projects, :members, :member_roles, :roles, :users

  def setup
    @controller = MembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2
  end

  def test_members_routing
    assert_routing(
      {:method => :post, :path => 'projects/5234/members/new'},
      :controller => 'members', :action => 'new', :id => '5234'
    )
  end

  def test_create
    assert_difference 'Member.count' do
      post :new, :id => 1, :member => {:role_ids => [1], :user_id => 7}
    end
    assert_redirected_to '/projects/ecookbook/settings/members'
    assert User.find(7).member_of?(Project.find(1))
  end

  def test_create_multiple
    assert_difference 'Member.count', 3 do
      post :new, :id => 1, :member => {:role_ids => [1], :user_ids => [7, 8, 9]}
    end
    assert_redirected_to '/projects/ecookbook/settings/members'
    assert User.find(7).member_of?(Project.find(1))
  end

  def test_edit
    assert_no_difference 'Member.count' do
      post :edit, :id => 2, :member => {:role_ids => [1], :user_id => 3}
    end
    assert_redirected_to '/projects/ecookbook/settings/members'
  end

  def test_destroy
    assert_difference 'Member.count', -1 do
      post :destroy, :id => 2
    end
    assert_redirected_to '/projects/ecookbook/settings/members'
    assert !User.find(3).member_of?(Project.find(1))
  end

  def test_autocomplete_for_member
    get :autocomplete_for_member, :id => 1, :q => 'mis'
    assert_response :success
    assert_template 'autocomplete_for_member'

    assert_tag :label, :content => /User Misc/,
                       :child => { :tag => 'input', :attributes => { :name => 'member[user_ids][]', :value => '8' } }
  end
end
