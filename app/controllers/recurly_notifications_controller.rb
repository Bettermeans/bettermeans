# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class RecurlyNotificationsController < ApplicationController
  def listen
    logger.info { "params #{params.inspect}" }
    if params[:updated_subscription_notification]
      update_subscription(params[:updated_subscription_notification],true)
    end

    if params[:new_subscription_notification]
      update_subscription(params[:new_subscription_notification],true)
    end

    if params[:expired_subscription_notification]
      update_subscription(params[:expired_subscription_notification],false)
    end

    render :nothing => true
  end

  private

  def update_subscription(params,active_subscription)
    account = params["account"]
    subscription = params["subscription"]
    begin
      user = User.find(account["account_code"])

      if active_subscription
        user.plan_id = Plan.find_by_code(subscription["plan"]["plan_code"]).id
        user.active_subscription = true
      else
        user.plan_id = Plan.find(Plan::FREE_CODE).id
        user.active_subscription = false
      end
      user.save
      logger.info { "saved for user #{user.name} new plan #{user.plan_id}" }
    rescue Exception => e
      logger.info { e.inspect }
    end

  end
end
