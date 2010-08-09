# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class MyController < ApplicationController
  before_filter :require_login
  ssl_required :page, :upgrade, :account, :password
  

  helper :issues

  BLOCKS = { 'issuesassignedtome' => :label_assigned_to_me_issues,
             'issuesreportedbyme' => :label_reported_issues,
             'issueswatched' => :label_watched_issues,
             'news' => :label_news_latest,
             'calendar' => :label_calendar,
             'documents' => :label_document_plural
           }.merge(Redmine::Views::MyPage::Block.additional_blocks).freeze

  DEFAULT_LAYOUT = {  'left' => ['issuesassignedtome'], 
                      'right' => ['issuesreportedbyme'] 
                   }.freeze

  verify :xhr => true,
         :only => [:add_block, :remove_block, :order_blocks]

  def index
    page
    render :action => 'page'
  end

  # Show user's page
  def page
    @user = User.current
    @blocks = @user.pref[:my_page_layout] || DEFAULT_LAYOUT
  end

  # Edit user's account
  def account
    @user = User.current
    @pref = @user.pref
    if request.post?
      cc = params[:user][:b_cc_last_four]
      
      if cc && cc.length > 14
        cc.gsub!(/[^0-9]/,'')
        params[:user][:b_cc_last_four] = ("XXXX-") + params[:user][:b_cc_last_four][cc.length-4,cc.length-1] if cc.length > 14
      end
      @user.attributes = params[:user]
      @user.mail_notification = (params[:notification_option] == 'all')
      @user.pref.attributes = params[:pref]
      @user.pref[:no_self_notified] = (params[:no_self_notified] == '1')
      @user.pref[:no_emails] = (params[:no_emails] == '1')
      if @user.save
        @user.pref.save
        @user.save_billing cc, params[:ccverify], request.remote_ip
        @user.notified_project_ids = (params[:notification_option] == 'selected' ? params[:notified_project_ids] : [])
        set_language_if_valid @user.language
        flash[:notice] = l(:notice_account_updated)
        redirect_to :action => 'account'
        return
      end
    end
    @notification_options = [[l(:label_user_mail_option_all), 'all'],
                             [l(:label_user_mail_option_none), 'none']]
    # Only users that belong to more than 1 project can select projects for which they are notified
    # Note that @user.membership.size would fail since AR ignores :include association option when doing a count
    # @notification_options.insert 1, [l(:label_user_mail_option_selected), 'selected'] if @user.memberships.length > 1
    @notification_option = @user.mail_notification? ? 'all' : (@user.notified_projects_ids.empty? ? 'none' : 'selected')    
  end
  
  def upgrade
    @user = User.current
    @plans = Plan.all
    @selected_plan = @user.plan
    
    if request.post?
      cc = params[:user][:b_cc_last_four]
      cc.gsub!(/[^0-9]/,'')
      if cc.length > 14
        params[:user][:b_cc_last_four] = ("XXXX-") + params[:user][:b_cc_last_four][cc.length-4,cc.length-1]
      else
        params[:user].delete :b_cc_last_four
      end
      
      @new_plan = Plan.find(params[:user][:plan_id])
      @user.attributes = params[:user]
      @user.plan_id = @new_plan.id

      logger.info("new plan #{@new_plan.inspect}")
      account = User.update_recurly_billing @user.id, cc, params[:ccverify], request.remote_ip
        
      # logger.info { "hellooooooooo" } if account.billing_info.defined?
        
      if (defined? account.billing_info) && account.billing_info.errors && account.billing_info.errors.any?
        logger.info("error in updating billing: #{account.billing_info.inspect}")
        logger.info("errors in updating billing: #{account.billing_info.errors.inspect}")
        logger.info { "any? #{account.billing_info.errors.any?}" }
        
        flash[:error] = account.billing_info.errors[:base].collect {|v| "#{v}"}.join('<br>')
        logger.error { "error here please" }
        return
      end
              
      if @new_plan.code == Plan::FREE_CODE && @new_plan.code != @selected_plan.code
        begin
          sub = Recurly::Subscription.find(@user.id.to_s)
          sub.cancel(@user.id.to_s)
        rescue ActiveResource::ResourceNotFound
          logger.info { "couldn't get existing sub" }
          sub = Recurly::Subscription.create(
            :account_code => account.account_code,
            :plan_code => @new_plan.code, 
            :quantity => 1,
            :account => account
          )
        rescue Exception => e
          logger.info e.inspect
          flash[:error] = e.message
          return
        else
          @user.save
          flash[:notice] = "Your plan was successfully canceled"
          redirect_to :action => 'account'
          return
        end
      elsif @new_plan.code != @selected_plan.code
        begin
          sub = Recurly::Subscription.find(@user.id.to_s)
          logger.info { "Got existing sub #{sub.inspect}" }
          begin
          sub.change('now', :plan_code => @new_plan.code, :quantity => 1)
          rescue Exception => e
            logger.info e.inspect
            flash[:error] = e.message
            return
          end
        rescue ActiveResource::ResourceNotFound
          logger.info { "couldn't get existing sub" }
          sub = Recurly::Subscription.create(
            :account_code => account.account_code,
            :plan_code => @new_plan.code, 
            :quantity => 1,
            :account => account
          )
        end
        
        if sub.errors && sub.errors.any?
          flash[:error] = sub.errors.collect {|k, v| "#{v}"}.join('<br>')
          logger.info("error in cancelling billing: #{sub.errors.inspect}")
          logger.info("error in cancelling billing: #{sub.errors.base.inspect}")
          
          # logger.info sub.errors["base"].sub.collect {|k, v| "#{v}"}.join('<br>')
          
          return
        else
          @user.save
          flash[:notice] = "Plan successfully changed to #{@new_plan.name}"
        end
      else
        flash[:notice] = l(:notice_account_updated) + " No changes were made to your plan"
      end
      
      logger.info("subscription #{sub.inspect}")
      
      redirect_to :action => 'account'
      return
    end    
  end

  # Manage user's password
  def password
    @user = User.current
    if @user.auth_source_id
      flash[:error] = l(:notice_can_t_change_password)
      redirect_to :action => 'account'
      return
    end
    if request.post?
      if @user.check_password?(params[:password])
        @user.password, @user.password_confirmation = params[:new_password], params[:new_password_confirmation]
        if @user.save
          flash[:notice] = l(:notice_account_password_updated)
          redirect_to :action => 'account'
        end
      else
        flash[:error] = l(:notice_account_wrong_password)
      end
    end
  end
  
  # Create a new feeds key
  def reset_rss_key
    if request.post?
      if User.current.rss_token
        User.current.rss_token.destroy
        User.current.reload
      end
      User.current.rss_key
      flash[:notice] = l(:notice_feeds_access_key_reseted)
    end
    redirect_to :action => 'account'
  end

  # Create a new API key
  def reset_api_key
    if request.post?
      if User.current.api_token
        User.current.api_token.destroy
        User.current.reload
      end
      User.current.api_key
      flash[:notice] = l(:notice_api_access_key_reseted)
    end
    redirect_to :action => 'account'
  end

  # User's page layout configuration
  def page_layout
    @user = User.current
    @blocks = @user.pref[:my_page_layout] || DEFAULT_LAYOUT.dup
    @block_options = []
    BLOCKS.each {|k, v| @block_options << [l("my.blocks.#{v}", :default => [v, v.to_s.humanize]), k.dasherize]}
  end
  
  # Add a block to user's page
  # The block is added on top of the page
  # params[:block] : id of the block to add
  def add_block
    block = params[:block].to_s.underscore
    (render :nothing => true; return) unless block && (BLOCKS.keys.include? block)
    @user = User.current
    layout = @user.pref[:my_page_layout] || {}
    # remove if already present in a group
    %w(top left right).each {|f| (layout[f] ||= []).delete block }
    # add it on top
    layout['top'].unshift block
    @user.pref[:my_page_layout] = layout
    @user.pref.save 
    render :partial => "block", :locals => {:user => @user, :block_name => block}
  end
  
  # Remove a block to user's page
  # params[:block] : id of the block to remove
  def remove_block
    block = params[:block].to_s.underscore
    @user = User.current
    # remove block in all groups
    layout = @user.pref[:my_page_layout] || {}
    %w(top left right).each {|f| (layout[f] ||= []).delete block }
    @user.pref[:my_page_layout] = layout
    @user.pref.save 
    render :nothing => true
  end

  # Change blocks order on user's page
  # params[:group] : group to order (top, left or right)
  # params[:list-(top|left|right)] : array of block ids of the group
  def order_blocks
    group = params[:group]
    @user = User.current
    if group.is_a?(String)
      group_items = (params["list-#{group}"] || []).collect(&:underscore)
      if group_items and group_items.is_a? Array
        layout = @user.pref[:my_page_layout] || {}
        # remove group blocks if they are presents in other groups
        %w(top left right).each {|f|
          layout[f] = (layout[f] || []) - group_items
        }
        layout[group] = group_items
        @user.pref[:my_page_layout] = layout
        @user.pref.save 
      end
    end
    render :nothing => true
  end
end
