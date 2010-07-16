class HomeController < ApplicationController
  layout 'static'
  def index
    # render the landing page
    if User.current.logged?
      logger.info("we have a current user #{current_user.inspect}")
      redirect_to :controller => 'welcome', :action => 'index'
    else
      redirect_to :controller => 'home', :action => 'show', :page => 'index'
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