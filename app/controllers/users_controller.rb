# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class UsersController < ApplicationController

  before_filter :require_admin, :except => [:show, :rpx_token]
  ssl_required :all


  helper :sort
  include SortHelper

  def index
    sort_init 'login', 'asc'
    sort_update %w(login firstname lastname mail admin created_at last_login_on)

    @status = params[:status] ? params[:status].to_i : 1
    c = ARCondition.new(@status == 0 ? "status <> 0" : ["status = ?", @status])

    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      c << ["LOWER(login) LIKE ? OR LOWER(firstname) LIKE ? OR LOWER(lastname) LIKE ? OR LOWER(mail) LIKE ?", name, name, name, name]
    end

    @user_count = User.count(:conditions => c.conditions)
    @user_pages = Paginator.new self, @user_count,
                per_page_option,
                params['page']
    @users =  User.find :all,:order => sort_clause,
                        :conditions => c.conditions,
            :limit  =>  @user_pages.items_per_page,
            :offset =>  @user_pages.current.offset

    render :layout => !request.xhr?
  end

  def show
    @user = User.find(params[:id])
    # if params[:login]
    #   @user = User.active.find_by_login(params[:login])
    #   if @user.nil?
    #     render_404
    #     return
    #   end
    # else
    #   @user = User.active.find(params[:id])
    # end

    # show only public projects and private projects that the logged in user is also a member of
    @memberships = @user.memberships.select do |membership|
      membership.project.visible_to(User.current)
    end

    # show only public projects and private projects that the logged in user is also a member of
    @reputations = @user.reputations.select do |reputation|
      reputation.project_id == 0 || reputation.project.visible_to(User.current)
    end

    # @activities_by_item = ActivityStream.fetch(@user, nil, nil, nil)


    # if @user != User.current && !User.current.admin? && @memberships.empty?
    #   render_404
    #   return
    # end

    flash.now[:notice] = l(:notice_this_is_your_profie) if @user == User.current

    render :layout => 'gooey'

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def add
    if request.get?
      @user = User.new(:language => Setting.default_language)
    else
      @user = User.new(params[:user])
      @user.admin = params[:user][:admin] || false
      @user.login = params[:user][:login]
      @user.password, @user.password_confirmation = params[:password], params[:password_confirmation] unless @user.auth_source_id
      if @user.save
        Mailer.deliver_account_information(@user, params[:password]) if params[:send_information]
        flash.now[:success] = l(:notice_successful_create)
        redirect_to(params[:continue] ? {:controller => 'users', :action => 'add'} :
                                        {:controller => 'users', :action => 'edit', :id => @user})
        return
      end
    end
    @auth_sources = AuthSource.find(:all)
  end

  def edit
    @user = User.find(params[:id])
    if request.post?
      @user.admin = params[:user][:admin] if params[:user][:admin]
      @user.login = params[:user][:login] if params[:user][:login]
      @user.password, @user.password_confirmation = params[:password], params[:password_confirmation] unless params[:password].nil? or params[:password].empty? or @user.auth_source_id
      @user.group_ids = params[:user][:group_ids] if params[:user][:group_ids]
      @user.attributes = params[:user]
      # Was the account actived ? (do it before User#save clears the change)
      was_activated = (@user.status_change == [User::STATUS_REGISTERED, User::STATUS_ACTIVE])
      if @user.save
        if was_activated
          Mailer.deliver_account_activated(@user)
        elsif @user.active? && params[:send_information] && !params[:password].blank? && @user.auth_source_id.nil?
          Mailer.deliver_account_information(@user, params[:password])
        end
        flash.now[:success] = l(:notice_successful_update)
        redirect_to :back
      end
    end
    @auth_sources = AuthSource.find(:all)
    @membership ||= Member.new
  rescue ::ActionController::RedirectBackError
    redirect_to :controller => 'users', :action => 'edit', :id => @user
  end

  def edit_membership
    @user = User.find(params[:id])
    @membership = params[:membership_id] ? Member.find(params[:membership_id]) : Member.new(:user => @user)
    @membership.attributes = params[:membership]
    @membership.save if request.post?
    respond_to do |format|
       format.html { redirect_to :controller => 'users', :action => 'edit', :id => @user, :tab => 'memberships' }
       format.js {
         render(:update) {|page|
           page.replace_html "tab-content-memberships", :partial => 'users/memberships'
           page.visual_effect(:highlight, "member-#{@membership.id}")
         }
       }
     end
  end

  def destroy_membership
    @user = User.find(params[:id])
    @membership = Member.find(params[:membership_id])
    if request.post? && @membership.deletable?
      @membership.destroy
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'users', :action => 'edit', :id => @user, :tab => 'memberships' }
      format.js { render(:update) {|page| page.replace_html "tab-content-memberships", :partial => 'users/memberships'} }
    end
  end

end
