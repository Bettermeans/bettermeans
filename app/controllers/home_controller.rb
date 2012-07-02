class HomeController < ApplicationController
  ssl_required :index
  layout 'static'
  def index
    # render the landing page
    if User.current.logged?
      redirect_to :controller => 'welcome', :action => 'index'
    else
      # redirect_to :controller => 'welcome', :action => 'index'
      redirect_to "/front/index.html"
      # redirect_to :controller => 'home', :action => 'show', :page => 'index'
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
