# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class RecurlyNotificationsController < ApplicationController
  def listen
    logger.info { "params #{params.inspect}" }
    if params[:updated_subscription_notification]
      updated_subscription(params[:updated_subscription_notification][:account],[:updated_subscription_notification][:subscription])
    end
    
    if params[:new_subscription_notification]
      updated_subscription(params[:new_subscription_notification][:account],[:new_subscription_notification][:subscription])
    end
    render :nothing => true
  end
  
  def update_subscription(account,subscription)
    begin
      user = User.find(account[:account_code])
      user.plan_id = subscription[:plan][:plan_code]
      user.trial_expires_on = new DateTime(subscription[:tiral_ends_at])
      user.active_subscription = true
    rescue Exception => e
      logger.info { e.inspect }
    end
    
  end
end