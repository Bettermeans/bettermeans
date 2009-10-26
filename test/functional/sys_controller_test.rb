# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'
require 'sys_controller'

# Re-raise errors caught by the controller.
class SysController; def rescue_action(e) raise e end; end

class SysControllerTest < ActionController::TestCase
  fixtures :projects, :repositories
  
  def setup
    @controller = SysController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Setting.sys_api_enabled = '1'
    Setting.enabled_scm = %w(Subversion Git)
  end
  
  def test_projects_with_repository_enabled
    get :projects
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    with_options :tag => 'projects' do |test|
      test.assert_tag :children => { :count  => Project.active.has_module(:repository).count }
    end
  end

  def test_create_project_repository
    assert_nil Project.find(4).repository
    
    post :create_project_repository, :id => 4, 
                                     :vendor => 'Subversion',
                                     :repository => { :url => 'file:///create/project/repository/subproject2'}
    assert_response :created
    
    r = Project.find(4).repository
    assert r.is_a?(Repository::Subversion)
    assert_equal 'file:///create/project/repository/subproject2', r.url
  end
end
