class HomeController < ApplicationController
  ssl_required :index
  layout 'static'
  def index
    if User.current.logged?
      redirect_to :controller => 'welcome', :action => 'index'
    else
      redirect_to "/front/index.html"
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
