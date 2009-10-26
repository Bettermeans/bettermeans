# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

class WorkflowsController < ApplicationController
  before_filter :require_admin

  def index
    @workflow_counts = Workflow.count_by_tracker_and_role
  end
  
  def edit
    @role = Role.find_by_id(params[:role_id])
    @tracker = Tracker.find_by_id(params[:tracker_id])    
    
    if request.post?
      Workflow.destroy_all( ["role_id=? and tracker_id=?", @role.id, @tracker.id])
      (params[:issue_status] || []).each { |old, news| 
        news.each { |new| 
          @role.workflows.build(:tracker_id => @tracker.id, :old_status_id => old, :new_status_id => new) 
        }
      }
      if @role.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'edit', :role_id => @role, :tracker_id => @tracker
      end
    end
    @roles = Role.find(:all, :order => 'builtin, position')
    @trackers = Tracker.find(:all, :order => 'position')
    @statuses = IssueStatus.find(:all, :order => 'position')
  end
end
