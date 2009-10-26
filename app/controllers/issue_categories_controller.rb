# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class IssueCategoriesController < ApplicationController
  menu_item :settings
  before_filter :find_project, :authorize
  
  verify :method => :post, :only => :destroy

  def edit
    if request.post? and @category.update_attributes(params[:category])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'projects', :action => 'settings', :tab => 'categories', :id => @project
    end
  end

  def destroy
    @issue_count = @category.issues.size
    if @issue_count == 0
      # No issue assigned to this category
      @category.destroy
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'categories'
    elsif params[:todo]
      reassign_to = @project.issue_categories.find_by_id(params[:reassign_to_id]) if params[:todo] == 'reassign'
      @category.destroy(reassign_to)
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'categories'
    end
    @categories = @project.issue_categories - [@category]
  end

private
  def find_project
    @category = IssueCategory.find(params[:id])
    @project = @category.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end    
end
