class EmailUpdatesController < ApplicationController
  before_filter :require_login
  ssl_required :all

  def new # spec_me cover_me heckle_me
    @email_update = EmailUpdate.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @invitation }
    end
  end

  def create # spec_me cover_me heckle_me
    @email_update = EmailUpdate.new(params[:email_update])
    @email_update.user = User.current

    respond_to do |format|
      if @email_update.save
        @email_update.send_activation
        format.html { redirect_with_flash :success, "Please check #{@email_update.mail} for the activation email", {:controller => :my, :action => "account"}  }
      else
        flash.now[:error] = "Couldn't create email update"
        format.html { render :action => "new" }
      end
    end
  end

  def activate # spec_me cover_me heckle_me
    @email_update = EmailUpdate.find_by_token(params[:token])

    if @email_update.nil?
      redirect_with_flash :error, l(:error_bad_email_update), :controller => :my, :action => :account
      return
    end

    @email_update.accept


    redirect_with_flash :success, l(:text_email_updated), :controller => :my, :action => :account
    return

  rescue ActiveRecord::RecordNotFound
    redirect_with_flash :error, l(:error_bad_email_update), :controller => :my, :action => :account
  end

end
