# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class TrackersController < ApplicationController
  layout 'admin'
  
  before_filter :require_admin
  ssl_required :all
  
  def index
    list
    render :action => 'list' unless request.xhr?
  end
  
  verify :method => :post, :only => :destroy, :redirect_to => { :action => :list }

  def list
    @tracker_pages, @trackers = paginate :trackers, :per_page => 10, :order => 'position'
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    @tracker = Tracker.new(params[:tracker])
    if request.post? and @tracker.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Tracker.find_by_id(params[:copy_workflow_from]))
        @tracker.workflows.copy(copy_from)
      end
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'list'
      return
    end
    @trackers = Tracker.find :all, :order => 'position'
    @projects = Project.find(:all)
  end

  def edit
    @tracker = Tracker.find(params[:id])
    if request.post? and @tracker.update_attributes(params[:tracker])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'list'
      return
    end
    @projects = Project.find(:all)
  end
  
  def destroy
    @tracker = Tracker.find(params[:id])
    unless @tracker.issues.empty?
      flash.now[:error] = "This tracker contains issues and can\'t be deleted."
    else
      @tracker.destroy
    end
    redirect_to :action => 'list'
  end

end
