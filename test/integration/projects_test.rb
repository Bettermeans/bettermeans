# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require "#{File.dirname(__FILE__)}/../test_helper"

class ProjectsTest < ActionController::IntegrationTest
  fixtures :projects, :users, :members
  
  def test_archive_project
    subproject = Project.find(1).children.first
    log_user("admin", "admin")
    get "admin/projects"
    assert_response :success
    assert_template "admin/projects"
    post "projects/archive", :id => 1
    assert_redirected_to "admin/projects"
    assert !Project.find(1).active?
    
    get 'projects/1'
    assert_response 403
    get "projects/#{subproject.id}"
    assert_response 403
    
    post "projects/unarchive", :id => 1
    assert_redirected_to "admin/projects"
    assert Project.find(1).active?
    get "projects/1"
    assert_response :success
  end  
end
