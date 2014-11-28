# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require 'uri'
require 'cgi'
require 'ruby-debug'

class ApplicationController < ActionController::Base
  include Redmine::I18n
  include LogActivityStreams

  before_filter :set_user_ip

  helper :all

  include SslRequirement
  # don't require ssl in development
  skip_before_filter :ensure_proper_protocol if Rails.env.development? || Rails.env.test?

  layout 'gooey'

  # Remove broken cookie after upgrade from 0.8.x (#4292)
  # See https://rails.lighthouseapp.com/projects/8994/tickets/3360
  # TODO: remove it when Rails is fixed
  before_filter :delete_broken_cookies
  def delete_broken_cookies # heckle_me
    if cookies['_redmine_session'] && cookies['_redmine_session'] !~ /--/
      cookies.delete '_redmine_session'
      redirect_to home_path
      return false
    end
  end

  before_filter :user_setup, :check_if_login_required, :set_localization
  filter_parameter_logging :password
  protect_from_forgery

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalid_authenticity_token

  include Redmine::Search::Controller
  include Redmine::MenuManager::MenuController
  helper Redmine::MenuManager::MenuHelper

  def set_user_ip # heckle_me
    session[:client_ip] ||= request.headers['X-Real-Ip']
  end

  def user_setup # heckle_me
    # Check the settings cache for each request
    Setting.check_cache
    # Find the current user
    User.current = find_current_user
  end

  def redirect_with_flash(flash_type,msg,*params) # heckle_me
    flash[flash_type] = msg
    redirect_to(*params)
  end

  def current_user # heckle_me
    User.current
  end

  # Sets the logged in user
  def logged_user=(user) # spec_me cover_me heckle_me
    #resetting session, but keeping client_ip
    ip = session[:client_ip] if session[:client_ip]
    reset_session
    session[:client_ip] = ip
    if user && user.is_a?(User)
      User.current = user
      session[:user_id] = user.id
    else
      User.current = User.anonymous
    end
  end

  # check if login is globally required to access the application
  def check_if_login_required # spec_me cover_me heckle_me
    # no check needed if user is already logged in
    return true if User.current.logged?
    require_login if Setting.login_required?
  end

  def set_localization # spec_me cover_me heckle_me
    I18n.locale = params[:locale] || I18n.default_locale

    lang = nil
    if User.current.logged?
      lang = find_language(User.current.language)
    end

    lang ||= I18n.locale
    set_language_if_valid(lang)
  end

  def data_admin_logged_in? # spec_me cover_me heckle_me
    return false
  end

  def require_login # spec_me cover_me heckle_me
    if !User.current.logged?
      # Extract only the basic url parameters on non-GET requests
      if request.get?
        url = url_for(params)
      else
        url = url_for(:controller => params[:controller], :action => params[:action], :id => params[:id], :project_id => params[:project_id])
      end
      respond_to do |format|
        format.html { redirect_to :controller => "account", :action => "login", :back_url => url }
        format.xml { head :unauthorized }
        format.json { head :unauthorized }
      end
      return false
    end
    true
  end

  def require_admin # spec_me cover_me heckle_me
    return unless require_login
    if !User.current.admin?
      render_403
      return false
    end
    true
  end

  def deny_access # spec_me cover_me heckle_me
    User.current.logged? ? render_403 : require_login
  end

  # Authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action], global = false) # spec_me cover_me heckle_me
    return true if params[:format] == "png"
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, @project, :global => global)
    allowed ? true : deny_access
  end

  # Authorize the user for the requested action outside a project
  def authorize_global(ctrl = params[:controller], action = params[:action], global = true) # spec_me cover_me heckle_me
    authorize(ctrl, action, global)
  end

  # make sure that the user is a member of the project (or admin) if project is private
  # used as a before_filter for actions that do not require any particular permission on the project
  def check_project_privacy # cover_me heckle_me
    if @project && @project.active?
      if @project.is_public? || User.current.allowed_to_see_project?(@project) || User.current.admin?
        true
      else
        User.current.logged? ? render_403 : require_login
      end
    else
      @project = nil
      render_404
      false
    end
  end

  def redirect_back_or_default(default) # cover_me heckle_me
    back_url = CGI.unescape(params[:back_url].to_s)
    if !back_url.blank? && !back_url.include?("/home/") && !back_url.include?("/front/")
      begin
        uri = URI.parse(back_url)

        # do not redirect user to another host or to the login or register page
        if (uri.relative? || (uri.host == request.host)) && !uri.path.match(%r{/(login|account/register)})
          redirect_to(back_url)
          return
        end
      rescue URI::InvalidURIError
        # redirect to default
      end
    end
    redirect_to default
  end

  def render_403 # cover_me heckle_me
    @project = nil
    render :template => "common/403", :layout => (request.xhr? ? false : 'gooey'), :status => 403
    return false
  end

  def render_404 # cover_me heckle_me
    render :template => "common/404", :layout => !request.xhr?, :status => 404
    return false
  end

  def render_error(msg) # cover_me heckle_me
    flash.now[:error] = msg
    render :text => '', :layout => !request.xhr?, :status => 500
  end

  def render_message(msg) # cover_me heckle_me
    flash.now[:notice] = msg
    render :text => '', :layout => !request.xhr?
  end

  def invalid_authenticity_token # cover_me heckle_me
    redirect_back_or_default(home_path)
  end

  def self.accept_key_auth(*actions) # cover_me heckle_me
    actions = actions.flatten.map(&:to_s)
    write_inheritable_attribute('accept_key_auth_actions', actions)
  end

  def accept_key_auth_actions # cover_me heckle_me
    self.class.read_inheritable_attribute('accept_key_auth_actions') || []
  end

  # TODO: move to model
  def attach_files(obj, attachments) # cover_me heckle_me
    attached = []
    unsaved = []
    if attachments && attachments.is_a?(Hash)
      attachments.each_value do |attachment|
        file = attachment['file']
        next unless file && file.size > 0
        a = Attachment.create(:container => obj,
                              :file => file,
                              :description => attachment['description'].to_s.strip,
                              :author => User.current)
        a.new_record? ? (unsaved << a) : (attached << a)
      end
      if unsaved.any?
        flash.now[:error] = l(:warning_attachments_not_saved, unsaved.size)
      end
    end
    attached
  end

  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text) # cover_me heckle_me
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
  end

  # Returns the number of objects that should be displayed
  # on the paginated list
  def per_page_option # cover_me heckle_me
    per_page = nil
    if params[:per_page] && Setting.per_page_options_array.include?(params[:per_page].to_s.to_i)
      per_page = params[:per_page].to_s.to_i
      session[:per_page] = per_page
    elsif session[:per_page]
      per_page = session[:per_page]
    else
      per_page = Setting.per_page_options_array.first || 25
    end
    per_page
  end

  private

  # Returns the current user or nil if no user is logged in
  # and starts a session if needed
  def find_current_user # cover_me heckle_me
    if session[:user_id]
      # existing session
      user = (User.active.find(session[:user_id]) rescue nil)
      user
    elsif cookies[:autologin] && Setting.autologin?
      # auto-login feature starts a new session
      user = User.try_to_autologin(cookies[:autologin])
      session[:user_id] = user.id if user
      Track.log(Track::LOGIN,session[:client_ip]) if user
      user
    elsif Setting.rest_api_enabled? && ['xml', 'json'].include?(params[:format]) && accept_key_auth_actions.include?(params[:action])
      if params[:key].present?
        # Use API key
        User.find_by_api_key(params[:key])
      else
        # HTTP Basic, either username/password or API key/random
        authenticate_with_http_basic do |username, password|
          #TODO: track login here: Track.log(Track::LOGIN,session[:client_ip])
          User.authenticate(username, password) || User.find_by_api_key(username)
        end
      end
    end
  end

end
