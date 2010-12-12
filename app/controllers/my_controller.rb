# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class MyController < ApplicationController
  before_filter :require_login
  ssl_required :all  
  

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
  
  def projects
    @my_projects = User.current.owned_projects
    @belong_to_projects = User.current.belongs_to_projects
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
      logger.info { "@user.attributes #{@user.attributes.inspect}" }
      @user.mail_notification = (params[:notification_option] == 'all')
      
      logger.info { "params[:pref] #{params[:pref].inspect}" }
      @user.pref.attributes = params[:pref]
      logger.info { "@user.pref.attributes #{@user.pref.inspect}" }
      logger.info { "params[:active_only_jumps] #{params[:active_only_jumps]}  and boolean #{params[:active_only_jumps] == '1'}" }
      
      @user.pref[:no_self_notified] = (params[:no_self_notified] == '1')
      @user.pref[:daily_digest] = (params[:daily_digest] == '1')
      @user.pref[:no_emails] = (params[:no_emails] == '1')
      @user.pref[:hide_mail] = (params[:pref][:hide_mail] == '1')
      @user.pref[:active_only_jumps] = (params[:pref][:active_only_jumps] == '1')
      
      logger.info { "user pref #{@user.pref.inspect}" }
      if @user.save
        @user.pref.save
        @user.reload
        @user.save_billing cc, params[:ccverify], request.remote_ip
        @user.notified_project_ids = (params[:notification_option] == 'selected' ? params[:notified_project_ids] : [])
        set_language_if_valid @user.language
        redirect_with_flash :notice, l(:notice_account_updated), :action => 'account'
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
      @user.save
          
      account = User.update_recurly_billing @user.id, cc, params[:ccverify], request.remote_ip
        
      if (defined? account.billing_info) && account.billing_info.errors && account.billing_info.errors.any?
        flash.now[:error] = account.billing_info.errors[:base].collect {|v| "#{v}"}.join('<br>')
        return
      end
              
      if @new_plan.code == Plan::FREE_CODE && @new_plan.code != @selected_plan.code
        begin
          sub = Recurly::Subscription.find(@user.id.to_s)
          sub.cancel(@user.id.to_s)
        rescue ActiveResource::ResourceNotFound
          sub = Recurly::Subscription.create(
            :account_code => account.account_code,
            :plan_code => @new_plan.code, 
            :quantity => 1,
            :account => account
          )
        rescue Exception => e
          flash.now[:error] = e.message
          return
        else
          @user.save
          flash.now[:success] = "Your plan was successfully canceled"
          # redirect_to :action => 'account'
          @user.reload
          return
        end
      elsif @new_plan.code != @selected_plan.code
        begin
          sub = Recurly::Subscription.find(@user.id.to_s)
          begin
          sub.change('now', :plan_code => @new_plan.code, :quantity => 1)
          rescue Exception => e
            flash.now[:error] = e.message
            return
          end
        rescue ActiveResource::ResourceNotFound
          trial_expiration = @user.trial_expires_on || -1.days.from_now
          sub = Recurly::Subscription.create(
            :account_code => account.account_code,
            :plan_code => @new_plan.code, 
            :quantity => 1,
            :account => account,
            :trial_ends_at => trial_expiration
          )
        end
        
        if sub.errors && sub.errors.any?
          flash.now[:error] = sub.errors.collect {|k, v| "#{v}"}.join('<br>')
          return
        else
          @user.save
          flash.now[:success] = "Plan successfully changed to #{@new_plan.name}"
        end
      else
        flash.now[:success] = l(:notice_account_updated) + " No changes were made to your plan"
      end
      @user.reload
      
      # redirect_to :action => 'account'
      return
    end    
  end

  # Manage user's password
  def password
    @user = User.current
    if @user.auth_source_id
      flash.now[:error] = l(:notice_can_t_change_password)
      redirect_to :action => 'account'
      return
    end
    if request.post?
      if @user.check_password?(params[:password])
        @user.password, @user.password_confirmation = params[:new_password], params[:new_password_confirmation]
        if @user.save
          flash.now[:success] = l(:notice_account_password_updated)
          redirect_to :action => 'account'
        end
      else
        flash.now[:error] = l(:notice_account_wrong_password)
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
      flash.now[:success] = l(:notice_feeds_access_key_reseted)
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
      flash.now[:success] = l(:notice_api_access_key_reseted)
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
