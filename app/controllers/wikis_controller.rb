# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class WikisController < ApplicationController
  menu_item :settings
  before_filter :find_project, :authorize
  ssl_required :edit
  
  # Create or update a project's wiki
  def edit
    @wiki = @project.wiki || Wiki.new(:project => @project)
    @wiki.attributes = params[:wiki]
    @wiki.save if request.post?
    render(:update) {|page| page.replace_html "tab-content-wiki", :partial => 'projects/settings/wiki'}
  end

  # Delete a project's wiki
  def destroy
    if request.post? && params[:confirm] && @project.wiki
      @project.wiki.destroy
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'wiki'
    end    
  end
  
private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
