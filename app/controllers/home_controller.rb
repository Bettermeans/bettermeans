class HomeController < ApplicationController
  layout 'static'
  def index
    # render the landing page
    if current_user
      logger.info("we have a current user #{current_user.inspect}")
      render :controller => 'welcome', :action => 'index'
    else
      render :action => 'show', :page => 'index'
    end
  end

  def show
    render :action => params[:page]
  end
  
  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
  
end

#link_to 'About', home_path('about')