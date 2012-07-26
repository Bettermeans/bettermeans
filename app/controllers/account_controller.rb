# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

class AccountController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:rpx_token, :register] # RPX does not pass Rails form tokens...

  # prevents login action to be filtered by check_if_login_required application scope filter
  skip_before_filter :check_if_login_required, :except => [:cancel]
  ssl_required :all

  # Login request and validation
  def login
    session[:invitation_token] = params[:invitation_token] || session[:invitation_token]
    @invitation_token = session[:invitation_token]

    if request.get?
      # Logout user
      self.logged_user = nil
      session[:invitation_token] = @invitation_token
      render :layout => 'static'
    else
      logger.info { "1 authenticating and accepting invitation #{session[:invitation_token]}" }
      # Authenticate user
      if Setting.openid? && using_open_id?
        open_id_authenticate(params[:openid_url])
      else
        password_authentication(@invitation_token)
      end
    end
  end

  # user_data
  # found: {:name=>'John Doe', :username => 'john', :email=>'john@doe.com', :identifier=>'blug.google.com/openid/dsdfsdfs3f3'}
  # not found: nil (can happen with e.g. invalid tokens)
  def rpx_token
    raise "hackers?" unless data = RPXNow.user_data(params[:token])

    if session[:invitation_token]
      invitation = Invitation.find_by_token(session[:invitation_token])
      invitation_mail = invitation.mail if invitation
      @invitation_token = session[:invitation_token]
      logger.info { "we have an invitation here #{invitation.inspect} session token #{session[:invitation_token]}" }
    end

    logger.info { "all data #{data.inspect}" }
    @user = User.find_by_identifier(data[:identifier])
    logger.info { "did we find user #{@user}" }
    if !@user
      @user = User.find_by_mail(data[:email]) if data[:email]

      if @user
        @user.identifier = data[:identifier]
        @user.save
      else #couldn't find user, we create one
        name = data[:name] || data[:username]
        mail = data[:email] || invitation_mail || "#{(0...8).map{65.+(rand(25)).chr}.join}_noemail@bettermeans.com" #twitter accounts don't give email so we generate a random one
        newdata = {:firstname => name, :mail => mail, :identifier => data[:identifier]}
        logger.info { "new data #{newdata.inspect}" }
        @user = User.new(newdata)

        #try and find a good login
        login = data[:username].gsub(/ /,"_").gsub(/'|\"|<|>/,"_")
        if !User.find_by_login(login)
          @user.login = login
        elsif !User.find_by_login(name.gsub(/ /,"_"))
          @user.login = name.gsub(/ /,"_")
        else
          @user.login = data[:email]
        end

        if invitation
          invitation.new_mail = @user.mail
          invitation.save
        end

        # @user.hashed_password = "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8" #just testing
        unless @user.save
          session[:debug_user] = @user.inspect
          session[:debug_data] = data.inspect if data
          raise "Couldn't create new account"
        end
      end
    else
      if invitation
        invitation.new_mail = @user.mail
        invitation.save
      end
    end

    logger.info { "WE ARE HERE! Almost authenticating for user #{@user.inspect}" }

    unless @user.active?
      @user.reactivate
      msg = l(:notice_account_reactivated)
    end
    successful_authentication(@user,@invitation_token,msg)
  end


  # Log out current user and redirect to welcome page
  def logout
    cookies.delete :autologin
    Token.delete_all(["user_id = ? AND action = ?", User.current.id, 'autologin']) if User.current.logged?
    self.logged_user = nil
    redirect_to home_url
  end

  # Enable user to choose a new password
  def lost_password
    redirect_to(home_url) && return unless Setting.lost_password?
    if params[:token]
      @token = Token.find_by_action_and_value("recovery", params[:token])
      redirect_to(home_url) && return unless @token and !@token.expired?
      @user = @token.user
      if request.post?
        @user.password, @user.password_confirmation = params[:new_password], params[:new_password_confirmation]
        if @user.save
          @token.destroy
          flash.now[:success] = l(:notice_account_password_updated)
          render :action => 'login', :layout => 'static'
          return
        end
      end
      render :template => "account/password_recovery"
      return
    else
      if request.post?
        user = User.find_by_mail(params[:mail])
        # user not found in db
        (flash.now[:error] = l(:notice_account_unknown_email); return) unless user
        # user uses an external authentification
        (flash.now[:error] = l(:notice_can_t_change_password); return) if user.auth_source_id
        # create a new token for password recovery
        token = Token.new(:user => user, :action => "recovery")
        if token.save
          Mailer.send_later(:deliver_lost_password,token)
          flash.now[:success] = l(:notice_account_lost_email_sent)
          render :action => 'login', :layout => 'static'
          return
        end
      end
    end
  end

  # User self-registration
  def register
    redirect_to(home_url) && return unless Setting.self_registration? || session[:auth_source_registration]

    if params[:plan]# && params[:plan].is_a?(Numeric)
      @plan_id = Plan.find_by_code(params[:plan]).id
    elsif params[:plan_id]# && params[:plan].is_a?(Numeric)
      @plan_id = params[:plan_id]
    else
      @plan_id = Plan.find_by_code(Plan::FREE_CODE).id
    end

    if request.get?
      session[:auth_source_registration] = nil
      self.logged_user = nil

      @user = User.new(:language => Setting.default_language)

      if params[:invitation_token]
        session[:invitation_token] = params[:invitation_token]
        invitation = Invitation.find_by_token params[:invitation_token]
        @user.mail = invitation.mail if invitation
        flash.now[:notice] = "Sign up below to activate your inviation.<br><br><a href='/login?invitation_token=#{params[:invitation_token]}'>Login here if you already have an account.</a>"
      end
    else
      @user = User.new(params[:user])
      logger.info { "params plan #{params[:plan]}" }

      @user.plan_id = @plan_id


      @user.trial_expires_on = 30.days.from_now if @user.plan_id && !@user.plan.free?

      @user.admin = false
      @user.status = User::STATUS_REGISTERED
      if session[:auth_source_registration]
        @user.status = User::STATUS_ACTIVE
        @user.login = session[:auth_source_registration][:login]
        @user.auth_source_id = session[:auth_source_registration][:auth_source_id]
        if @user.save
          session[:auth_source_registration] = nil
          self.logged_user = @user
          Track.log(Track::LOGIN,session[:client_ip])
          redirect_with_flash :notice, l(:notice_account_activated), :controller => 'my', :action => 'account'
        end
      else
        @user.login = params[:user][:login]
        @user.password, @user.password_confirmation = params[:password], params[:password_confirmation]

        case Setting.self_registration
        when '1'
          return if register_by_email_activation(@user,params[:invitation_token])
        when '3'
          register_automatically(@user)
        else
          register_manually_by_administrator(@user)
        end
      end
    end
    render :layout => 'static'
  end

  # Token based account activation
  def activate
    redirect_to(home_url) && return unless Setting.self_registration? && params[:token]
    token = Token.find_by_action_and_value('register', params[:token])
    redirect_to(home_url) && return unless token and !token.expired?
    user = token.user
    redirect_to(home_url) && return unless user.status == User::STATUS_REGISTERED
    user.status = User::STATUS_ACTIVE
    if user.save
      token.destroy
      flash.now[:success] = l(:notice_account_activated)
      successful_authentication(user)
    else
      render :action => 'login', :layout => 'static'
    end

  end

  def cancel
    User.current.cancel
    render_message(l(:notice_account_canceled))
  end

  private

  def password_authentication(invitation_token=nil)
    user = User.try_to_login(params[:username], params[:password])
    logger.info { "user #{user.inspect}" }

    if user.nil?
      invalid_credentials
    elsif user.new_record?
      onthefly_creation_failed(user, {:login => user.login, :auth_source_id => user.auth_source_id })
    elsif !user.active?
      inactive_user
    else
      # Valid user
      logger.info { "valid user" }
      if user.active?
        successful_authentication(user,invitation_token)
      else
        account_pending
      end
    end
  end


  def open_id_authenticate(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :fullname, :email], :return_to => signin_url) do |result, identity_url, registration|
      if result.successful?
        user = User.find_or_initialize_by_identity_url(identity_url)
        if user.new_record?
          # Self-registration off
          redirect_to(home_url) && return unless Setting.self_registration?

          # Create on the fly
          user.login = registration['nickname'] unless registration['nickname'].nil?
          user.mail = registration['email'] unless registration['email'].nil?
          user.firstname, user.lastname = registration['fullname'].split(' ') unless registration['fullname'].nil?
          user.random_password
          user.status = User::STATUS_REGISTERED

          case Setting.self_registration
          when '1'
            register_by_email_activation(user) do
              onthefly_creation_failed(user)
            end
          when '3'
            register_automatically(user) do
              onthefly_creation_failed(user)
            end
          else
            register_manually_by_administrator(user) do
              onthefly_creation_failed(user)
            end
          end
        else
          # Existing record
          if user.active?
            successful_authentication(user)
          else
            account_pending
          end
        end
      end
    end
  end

  def successful_authentication(user, invitation_token = nil, msg=nil)
    logger.info { "successful authentication baby #{user.inspect}" }
    # Valid user
    self.logged_user = user
    Track.log(Track::LOGIN,session[:client_ip])

    if invitation_token
      logger.info { "accepting invitation #{invitation_token}" }
      invitation = Invitation.find_by_token(invitation_token)
      invitation.accept(user) if invitation
    end


    # generate a key and set cookie if autologin
    if params[:autologin] && Setting.autologin?
      token = Token.create(:user => user, :action => 'autologin')
      cookies[:autologin] = { :value => token.value, :expires => 1.year.from_now }
    end

    if msg
      render_message(msg)
    else
      redirect_back_or_default :controller => 'welcome', :action => 'index'
    end
  end

  # Onthefly creation failed, display the registration form to fill/fix attributes
  def onthefly_creation_failed(user, auth_source_options = { })
    @user = user
    session[:auth_source_registration] = auth_source_options unless auth_source_options.empty?
    render :action => 'register'
  end

  def invalid_credentials
    flash.now[:error] = l(:notice_account_invalid_creditentials)
    render :layout => 'static'
  end

  def inactive_user
    logger.info { "inactive user!!!!" }
    flash.now[:error] = l(:notice_account_inactive_user)
    render_error(l(:notice_account_inactive_user))
  end


  # Register a user for email activation.
  #
  # Pass a block for behavior when a user fails to save
  def register_by_email_activation(user, invitation_token = nil)

    unless invitation_token.empty? || invitation_token.nil?
      logger.info { "invitation token #{invitation_token} is nil #{invitation_token.nil?}" }
      invitation = Invitation.find_by_token invitation_token
      invitation.new_mail = user.mail
      invitation.save
    end

    if invitation && invitation.mail == user.mail
      return register_automatically(user)
    end

    token = Token.new(:user => user, :action => "register")
    if user.save and token.save
      Mailer.send_later(:deliver_register,token)
      flash.now[:success] = l(:notice_account_register_done)
      render :action => 'login', :layout => 'static'
      return true
    else
      yield if block_given?
      return false
    end
  end

  # Automatically register a user
  #
  # Pass a block for behavior when a user fails to save
  def register_automatically(user, &block)
    # Automatic activation
    user.status = User::STATUS_ACTIVE
    user.last_login_on = Time.now
    if user.save
      self.logged_user = user
      Track.log(Track::LOGIN,session[:client_ip])
      redirect_with_flash :success, l(:notice_account_activated), :controller => 'welcome', :action => 'index'
      return true
    else
      yield if block_given?
      return false
    end
  end

  # Manual activation by the administrator
  #
  # Pass a block for behavior when a user fails to save
  def register_manually_by_administrator(user, &block)
    if user.save
      # Sends an email to the administrators
      Mailer.send_later(:deliver_account_activation_request,user)
      account_pending
    else
      yield if block_given?
    end
  end

  def account_pending
    flash.now[:notice] = l(:notice_account_pending)
    render :action => 'login', :layout => 'static'
  end
end
