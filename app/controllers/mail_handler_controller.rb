# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
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

  # Submits an incoming email from sendgrid to MailHandler
  def sendgrid
    @email = TMail::Mail.new
    @email.subject = params[:subject]
    @email.body = params[:text].to_s.gsub(/"/,'\"')
    @email.to = params[:to]
    @email.from = params[:from]
    @email.subject = params[:subject]

    logger.info { "email coming up" }
    logger.info(@email.inspect)
    #   attachments - Number of attachments included in email
    # *
    #   attachment1, attachment2, …, attachmentN - File upload names. The numbers are sequence numbers starting from 1 and ending on the number specified by the attachments parameter. If attachments is 0, there will be no attachment files. If attachments is 3, parameters attachment1, attachment2, and attachment3 will have file uploads.


    if MailHandler.receive_from_api(@email)
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
