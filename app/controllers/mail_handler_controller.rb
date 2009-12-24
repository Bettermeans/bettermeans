# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

class MailHandlerController < ActionController::Base
  before_filter :check_credential
  
  verify :method => :post,
         :only => :index,
         :render => { :nothing => true, :status => 405 }
         
  # Submits an incoming email to MailHandler
  def index
    options = params.dup
    email = options.delete(:email)
    if MailHandler.receive(email, options)
      render :nothing => true, :status => :created
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end
  
  private
  
  def check_credential
    User.current = nil
    unless Setting.mail_handler_api_enabled? && params[:key].to_s == Setting.mail_handler_api_key
      render :text => 'Access denied. Incoming emails WS is disabled or key is invalid.', :status => 403
    end
  end
end
