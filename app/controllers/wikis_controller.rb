# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class WikisController < ApplicationController
  menu_item :settings
  before_filter :find_project, :authorize
  ssl_required :all

  # Create or update a project's wiki
  def edit # spec_me cover_me heckle_me
    @wiki = @project.wiki || Wiki.new(:project => @project)
    @wiki.attributes = params[:wiki]
    @wiki.save if request.post?
    render(:update) {|page| page.replace_html "tab-content-wiki", :partial => 'projects/settings/wiki'}
  end

  # Delete a project's wiki
  def destroy # spec_me cover_me heckle_me
    if request.post? && params[:confirm] && @project.wiki
      @project.wiki.destroy
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'wiki'
    end
  end

  private

  def find_project # cover_me heckle_me
    @project = Project.find(params[:id])
    render_message l(:text_project_locked) if @project.locked?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
