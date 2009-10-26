# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class VersionsController < ApplicationController
  menu_item :roadmap
  before_filter :find_project, :authorize

  def show
  end
  
  def edit
    if request.post? and @version.update_attributes(params[:version])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => @project
    end
  end

  def destroy
    @version.destroy
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => @project
  rescue
    flash[:error] = l(:notice_unable_delete_version)
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'versions', :id => @project
  end
  
  def status_by
    respond_to do |format|
      format.html { render :action => 'show' }
      format.js { render(:update) {|page| page.replace_html 'status_by', render_issue_status_by(@version, params[:status_by])} }
    end
  end

private
  def find_project
    @version = Version.find(params[:id])
    @project = @version.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end  
end
