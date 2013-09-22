class HomeController < ApplicationController
  ssl_required :index
  layout 'static'
  def index # spec_me cover_me heckle_me
    if User.current.logged?
      redirect_to :controller => 'welcome', :action => 'index'
    else
      redirect_to "/front/index.html"
    end
  end

  def show # spec_me cover_me heckle_me
    render :action => params[:page]
  end

  def robots # spec_me cover_me heckle_me
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end

end
