# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'
require 'reports_controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end


class ReportsControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_issue_report_routing
    assert_routing(
      {:method => :get, :path => '/projects/567/issues/report'},
      :controller => 'reports', :action => 'issue_report', :id => '567'
    )
    assert_routing(
      {:method => :get, :path => '/projects/567/issues/report/assigned_to'},
      :controller => 'reports', :action => 'issue_report', :id => '567', :detail => 'assigned_to'
    )

  end

  def test_issue_report
    get :issue_report, :id => 1
    assert_response :success
    assert_template 'issue_report'
  end

  def test_issue_report_details
    %w(tracker version priority category assigned_to author subproject).each do |detail|
      get :issue_report, :id => 1, :detail => detail
      assert_response :success
      assert_template 'issue_report_details'
    end
  end
end
