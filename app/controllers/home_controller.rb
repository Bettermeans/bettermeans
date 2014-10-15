class HomeController < ApplicationController
  ssl_required :index
  layout 'static'
  def index # cover_me heckle_me
    if User.current.logged?
      redirect_to :controller => 'welcome', :action => 'index'
    else
      redirect_to "/front/index.html"
    end
  end

  def show # cover_me heckle_me
    render :action => params[:page]
  end

end
