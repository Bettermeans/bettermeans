# TODO: rename this to something like SessionsController after integration specs are done
class AccountController < ApplicationController

  # RPX does not pass Rails form tokens...
  skip_before_filter :verify_authenticity_token, :only => [ :rpx_token, :register ]

  # prevents login action from being filtered by check_if_login_required application scope filter
  skip_before_filter :check_if_login_required, :except => [ :cancel ]
  ssl_required :all

  # Login request and validation
  def login
    set_invitation_token
    if request.get?
      logout_user
      session[:invitation_token] = @invitation_token
      render :layout => 'static'
    elsif open_id_authenticate?
      open_id_authenticate(params[:openid_url])
    else
      password_authentication(@invitation_token)
    end
  end

  def rpx_token
    find_user_by_identifier || find_user_by_mail || create_new_user
    message = reactivate_user
    successful_authentication(@user, @invitation_token, message)
  end

  # Log out current user and redirect to welcome page
  def logout
    cookies.delete :autologin
    current_user.delete_autologin_tokens
    logout_user
    redirect_to home_url
  end

  # Enable user to choose a new password
  def lost_password
    redirect_to(home_url) && return unless Setting.lost_password?
    validate_token || create_token
  end

  # User self-registration
  def register
    redirect_to(home_url) and return unless check_registration

    pick_plan
    if request.get?
      logout_and_invite
    else
      initialize_user_with_plan
      return if register_user_with_auth_source || register_user
    end
    render :layout => 'static'
  end

  # Token based account activation
  def activate
    redirect_to(home_url) && return unless can_activate?
    find_token('register')
    redirect_to(home_url) && return unless @token and !@token.expired?
    user = @token.user
    redirect_to(home_url) && return unless user.status == User::STATUS_REGISTERED
    user.status = User::STATUS_ACTIVE
    if user.save
      @token.destroy
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

    if user.nil?
      invalid_credentials
    elsif user.new_record?
      onthefly_creation_failed(user, {:login => user.login, :auth_source_id => user.auth_source_id })
    elsif !user.active?
      inactive_user
    else
      # Valid user
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
    # Valid user
    self.logged_user = user
    Track.log(Track::LOGIN,session[:client_ip])

    if invitation_token
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
    flash.now[:error] = l(:notice_account_inactive_user)
    render_error(l(:notice_account_inactive_user))
  end

  # Register a user for email activation.
  #
  # Pass a block for behavior when a user fails to save
  def register_by_email_activation(user, invitation_token = nil)

    # BUGBUG: this should just be `invitation_token.blank?`
    # when it's nil this throws an error
    unless invitation_token.empty? || invitation_token.nil?
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

  def random_email
    "#{(0...8).map{65.+(rand(25)).chr}.join}_noemail@bettermeans.com"
  end

  def data
    @data ||= RPXNow.user_data(params[:token])
    raise "hackers?" unless @data
    @data
  end

  def invitation
    return @invitation if defined? @invitation
    if session[:invitation_token]
      @invitation = Invitation.find_by_token(session[:invitation_token])
      @invitation_token = session[:invitation_token]
    end
    @invitation
  end

  def invitation_mail
    invitation.mail if invitation
  end

  def update_invitation
    invitation.update_attributes(:new_mail => @user.mail) if invitation
  end

  def find_user_by_identifier
    if @user = User.find_by_identifier(data[:identifier])
      update_invitation
      true
    end
  end

  def find_user_by_mail
    if data[:email] && @user = User.find_by_mail(data[:email])
      @user.update_attributes(:identifier => data[:identifier])
      true
    end
  end

  def create_new_user
    @user = User.new(:firstname => name,
                      :mail => mail,
                      :identifier => data[:identifier])

    @user.login = available_login
    update_invitation
    save_user_or_raise
  end

  def reactivate_user
    unless @user.active?
      @user.reactivate
      return l(:notice_account_reactivated)
    end
  end

  def save_user_or_raise
    unless @user.save
      session[:debug_user] = @user.inspect
      session[:debug_data] = data.inspect
      raise "Couldn't create new account"
    end
  end

  def name
    data[:name] || data[:username]
  end

  def mail
    # twitter accounts don't give email so we generate a random one
    # TODO: get a real email from the user, or don't require one
    data[:email] || invitation_mail || random_email
  end

  def available_login
    # BUGBUG: if data[:email] is nil this won't fail based on validations
    # should probably use mail from up above
    User.find_available_login([data[:username], name]) || data[:email]
  end

  def logout_user
    self.logged_user = nil
  end

  def set_invitation_token
    session[:invitation_token] = params[:invitation_token] || session[:invitation_token]
    @invitation_token = session[:invitation_token]
  end

  def open_id_authenticate?
    Setting.openid? && using_open_id?
  end

  def update_password
    # BUGBUG: password confirmation isn't validated when nil
    @user.password = params[:new_password]
    @user.password_confirmation = params[:new_password_confirmation]

    if @user.save
      @token.destroy
      flash.now[:success] = l(:notice_account_password_updated)
      render :action => 'login', :layout => 'static'
      true
    end
  end

  def valid_user
    user = User.find_by_mail(params[:mail])

    if user.nil?
      flash.now[:error] = l(:notice_account_unknown_email)
      nil
    elsif user.auth_source_id
      flash.now[:error] = l(:notice_can_t_change_password)
      nil
    else
      user
    end
  end

  def valid_token
    if token && !token.expired?
      token
    else
      redirect_to(home_url)
      nil
    end
  end

  def token
    find_token('recovery')
  end

  # TODO: should be able to somehow combine #token and #find_token
  def find_token(action)
    @token ||= if params[:token]
      Token.find_by_action_and_value(action, params[:token])
    end
  end

  def send_mail(token)
    Mailer.send_later(:deliver_lost_password, token)
    flash.now[:success] = l(:notice_account_lost_email_sent)
    render :action => 'login', :layout => 'static'
  end

  def validate_token
    if params[:token] && @token = valid_token
      @user = @token.user
      return true if request.post? && update_password
      render :template => "account/password_recovery"
      true
    end
  end

  def create_token
    if request.post? && user = valid_user
      token = Token.new(:user => user, :action => "recovery")
      token.save && send_mail(token)
    end
  end

  def pick_plan
    if params[:plan]
      @plan_id = Plan.find_by_code(params[:plan]).id
    elsif params[:plan_id]
      @plan_id = params[:plan_id]
    else
      @plan_id = Plan.find_by_code(Plan::FREE_CODE).id
    end
  end

  def register_user
    @user.login = params[:user][:login]
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    case Setting.self_registration
    when '1'
      register_by_email_activation(@user,params[:invitation_token])
    when '3'
      register_automatically(@user)
      false
    else
      register_manually_by_administrator(@user)
      false
    end
  end

  def invite_to_login
    session[:invitation_token] = params[:invitation_token]
    invitation = Invitation.find_by_token(params[:invitation_token])
    @user.mail = invitation.mail if invitation
    flash.now[:notice] = "Sign up below to activate your invitation." <<
                         "<br><br><a href='/login?invitation_token=" <<
                         "#{params[:invitation_token]}'>" <<
                         "Login here if you already have an account.</a>"
  end

  def initialize_user_with_plan
    @user = User.new(params[:user])
    @user.plan_id = @plan_id

    # TODO: it shouldn't be possible for @user.plan_id to be nil here
    @user.trial_expires_on = 30.days.from_now if @user.plan_id && !@user.plan.free?
    # TODO: admin is attr_protected in the model, so it shouldn't be necessary here
    @user.admin = false
    @user.status = User::STATUS_REGISTERED
  end

  def register_user_with_auth_source
    return false unless session[:auth_source_registration]
    @user.status = User::STATUS_ACTIVE
    @user.login = session[:auth_source_registration][:login]
    @user.auth_source_id = session[:auth_source_registration][:auth_source_id]

    if @user.save
      # TODO: this isn't necessary, as the session gets cleared in logged_user=
      session[:auth_source_registration] = nil
      self.logged_user = @user
      Track.log(Track::LOGIN,session[:client_ip])
      redirect_with_flash :notice, l(:notice_account_activated), :controller => 'my', :action => 'account'
      true
    end
  end

  def logout_and_invite
    # TODO: this isn't necessary, as the session gets cleared in logged_user=
    session[:auth_source_registration] = nil
    logout_user
    @user = User.new(:language => Setting.default_language)
    invite_to_login if params[:invitation_token]
  end

  def check_registration
    Setting.self_registration? || session[:auth_source_registration]
  end

  def can_activate?
    Setting.self_registration? && params[:token]
  end
end
