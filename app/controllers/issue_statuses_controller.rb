# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class IssueStatusesController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  ssl_required :all

  verify :method => :post, :only => [ :destroy, :create, :update, :move ],
         :redirect_to => { :action => :list }

  def index # spec_me cover_me heckle_me
    list
    render :action => 'list' unless request.xhr?
  end

  def list # spec_me cover_me heckle_me
    @issue_status_pages, @issue_statuses = paginate :issue_statuses, :per_page => 25, :order => "position"
    render :action => "list", :layout => false if request.xhr?
  end

  def new # spec_me cover_me heckle_me
    @issue_status = IssueStatus.new
  end

  def create # spec_me cover_me heckle_me
    @issue_status = IssueStatus.new(params[:issue_status])
    if @issue_status.save
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit # spec_me cover_me heckle_me
    @issue_status = IssueStatus.find(params[:id])
  end

  def update # spec_me cover_me heckle_me
    @issue_status = IssueStatus.find(params[:id])
    if @issue_status.update_attributes(params[:issue_status])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy # spec_me cover_me heckle_me
    IssueStatus.find(params[:id]).destroy
    redirect_to :action => 'list'
  rescue
    flash.now[:error] = "Unable to delete issue status"
    redirect_to :action => 'list'
  end
end
