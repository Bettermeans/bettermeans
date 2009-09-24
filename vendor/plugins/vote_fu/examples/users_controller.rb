# I usually use the user class from restful_authentication as my principle voter class
# There are generally no changes required to support voting in this controller. 

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # Protect these actions behind an admin login
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :show]

  before_filter :login_required, :only => [:index]

  # render new.html.erb
  def new
  end

  # GET /users/:id
  def show
  end
  

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def activate
    unless params[:activation_code].blank?
      self.current_user = User.find_by_activation_code(params[:activation_code])
      if logged_in? && !current_user.active?
        current_user.activate!
        flash[:notice] = "Signup complete!"
        redirect_back_or_default('/')
      else
        flash[:error] = "Sorry, we couldn't find that activation code. Please cut and paste your activation code into the space at left."
      end
    end
    # render activate.html.erb    
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
