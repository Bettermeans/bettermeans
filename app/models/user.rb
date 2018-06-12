# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#


require "digest/sha1"

class User < ActiveRecord::Base

  # TODO: change `mail` to `email`

  # Account statuses
  STATUS_ANONYMOUS  = 0
  STATUS_ACTIVE     = 1
  STATUS_REGISTERED = 2
  STATUS_LOCKED     = 3
  STATUS_CANCELED   = 4

  USER_FORMATS = {
    :firstname_lastname => '#{firstname} #{lastname}',
    :firstname => '#{firstname}',
    :lastname_firstname => '#{lastname} #{firstname}',
    :lastname_coma_firstname => '#{lastname}, #{firstname}',
    :username => '#{login}'
  }

  has_many :members, :foreign_key => 'user_id', :dependent => :destroy
  has_many :memberships, :class_name => 'Member', :foreign_key => 'user_id', :include => [ :project, :roles ], :conditions => "#{Project.table_name}.status=#{Project::STATUS_ACTIVE}", :order => "#{Project.table_name}.name"
  has_many :core_memberships, :class_name => 'Member', :foreign_key => 'user_id', :include => [ :project, :roles ], :conditions => "#{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Role.table_name}.builtin=#{Role::BUILTIN_CORE_MEMBER}", :order => "#{Project.table_name}.name"
  has_many :active_memberships, :class_name => 'Member', :foreign_key => 'user_id', :include => [ :project, :roles ], :conditions => "#{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Role.table_name}.builtin=#{Role::BUILTIN_ACTIVE}", :order => "#{Project.table_name}.name"
  has_many :projects, :through => :memberships
  has_many :owned_projects, :class_name => 'Project', :foreign_key => 'owner_id', :include => [:all_members]
  has_many :invitations
  has_many :activity_streams, :foreign_key => 'actor_id', :dependent => :delete_all

  # TODO: re-order relations
  has_one :preference, :dependent => :destroy, :class_name => 'UserPreference'
  has_one :rss_token, :dependent => :destroy, :class_name => 'Token', :conditions => "action='feeds'"
  has_one :api_token, :dependent => :destroy, :class_name => 'Token', :conditions => "action='api'"
  belongs_to :auth_source
  belongs_to :plan

  has_many :notifications, :foreign_key => 'recipient_id', :dependent => :delete_all

  has_many :shares, :foreign_key => :owner_id, :dependent => :nullify
  has_many :credits, :foreign_key => :owner_id, :dependent => :delete_all
  has_many :issue_votes, :dependent => :delete_all
  has_many :authored_todos, :class_name => 'Todo', :foreign_key => 'author_id', :dependent => :nullify
  has_many :owned_todos, :class_name => 'Todo', :foreign_key => 'owner_id', :dependent => :nullify

  has_many :outgoing_ratings, :class_name => 'RetroRating', :foreign_key => 'rater_id'
  has_many :incoming_ratings, :class_name => 'RetroRating', :foreign_key => 'ratee_id'
  has_many :credit_distributions
  has_many :reputations, :dependent => :delete_all
  has_many :help_sections
  has_many :tokens

  # Active non-anonymous users scope
  # TODO: change this to use array interpolation syntax
  named_scope :active, :conditions => "#{User.table_name}.status = #{STATUS_ACTIVE}"

  # TODO: double check that all the columns in the :order below are indexed
  named_scope :like, lambda {|q|
    s = "%#{q.to_s.strip.downcase}%"
    {:conditions => ["LOWER(login) LIKE :s OR LOWER(firstname) LIKE :s OR LOWER(lastname) LIKE :s OR LOWER(mail) LIKE :s", {:s => s}],
     :order => 'type, login, lastname, firstname, mail'
    }
  }

  has_private_messages :class_name => "Mail"

  attr_accessor :password, :password_confirmation
  attr_accessor :last_before_login_on
  # Prevents unauthorized assignments
  # TODO: password, password_confirmation should be mass assignable, and maybe login
  # this would be better as attr_accessor
  attr_protected :admin, :password, :password_confirmation, :hashed_password

  # BUGBUG: seems to be some bug here where it allows a nil email
  validates_presence_of :login, :firstname, :mail, :if => Proc.new { |user| !user.is_a?(AnonymousUser) }
  validates_uniqueness_of :login, :if => Proc.new { |user| !user.login.blank? }
  validates_uniqueness_of :mail, :if => Proc.new { |user| !user.mail.blank? }, :case_sensitive => false
  # Login must contain letters, numbers, underscores only
  validates_format_of :login, :with => /^[a-z0-9_@\.]*$/i
  validates_length_of :login, :maximum => 30
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i
  validates_length_of :firstname, :lastname, :maximum => 30
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_nil => true
  validates_length_of :mail, :maximum => 60, :allow_nil => true
  validates_confirmation_of :password, :allow_nil => true

  reportable :daily_registrations, :aggregation => :count, :limit => 14
  reportable :weekly_registrations, :aggregation => :count, :grouping => :week, :limit => 20

  # ===============
  # = CSV support =
  # ===============
  comma do  # implicitly named :default
    id
    login
    firstname
    lastname
    mail
    last_login_on
    created_at
    updated_at
    plan_id
    trial_expires_on
    active_subscription
  end

  def <=>(user) # spec_me cover_me heckle_me
    if self.class.name == user.class.name
      self.to_s.downcase <=> user.to_s.downcase
    else
      # groups after users
      user.class.name <=> self.class.name
    end
  end


  def before_create # spec_me cover_me heckle_me
    self.plan ||= Plan.free
    self.mail_notification = false
    self.login = self.login.downcase
    true
  end

  def before_save # spec_me cover_me heckle_me
    # update hashed_password if password was set
    self.hashed_password = User.hash_password(self.password) if self.password
    self.mail_hash =  Digest::MD5.hexdigest(self.mail) unless mail.nil?
  end

  def after_create # spec_me cover_me heckle_me
    activate_invitations
  end

  def activate_invitations # spec_me cover_me heckle_me
    Invitation.all(:conditions => {:new_mail => self.mail}).each do |invite|
      invite.accept
    end
  end

  def self.create_recurly_account(id) # spec_me cover_me heckle_me
    @user = User.find(id)
    begin
      @account = Recurly::Account.find(@user.id)
    rescue ActiveResource::ResourceNotFound
      @account = Recurly::Account.create(
        :account_code => @user.id,
        :first_name => @user.firstname,
        :last_name => @user.lastname,
        :email => @user.mail,
        :username => @user.login)
    end
  end

  def self.update_recurly_account(id) # spec_me cover_me heckle_me
    @user = User.find(id)

    begin
      @account = Recurly::Account.find(@user.id)
    rescue ActiveResource::ResourceNotFound
      @account = User.create_recurly_account(id)
    end

    @account.account_code = @user.id
    @account.first_name = @user.firstname
    @account.last_name = @user.lastname
    @account.email = @user.mail
    @account.username = @user.login
    @account.save
    @result_object = Recurly::Account.find(@account.account_code)
  end

  def self.update_recurly_billing(id,cc,ccverify,ip) # spec_me cover_me heckle_me
    @user = User.find(id)
    begin
      @account = Recurly::Account.find(@user.id)
    rescue ActiveResource::ResourceNotFound
      @account = User.create_recurly_account(id)
    end

    cc.gsub!(/[^0-9]/,'') if cc

    if cc && cc.length > 14
      @account.billing_info = Recurly::BillingInfo.create(
        :account_code => @account.account_code,
        :first_name => @account.first_name,
        :last_name => @account.last_name,
        :address1 => @user.b_address1,
        :zip => @user.b_zip,
        :country => @user.b_country,
        :city => "none",
        :state => "none",
        :phone => @user.b_phone,
        :ip_address => ip,
        :credit_card => {
          :number => cc,
          :year => @user.b_cc_year,
          :month => @user.b_cc_month,
          :verification_value => ccverify
        })

        return @account if @account.billing_info.errors

        @user.b_cc_type = @account.billing_info.credit_card.attributes["type"]
        @user.b_cc_last_four = "XXXX - " + @account.billing_info.credit_card.attributes["last_four"] + " " + @account.billing_info.credit_card.attributes["type"]
        @user.save
      else
        @account.billing_info = Recurly::BillingInfo.create(
          :account_code => @account.account_code,
          :first_name => @account.first_name,
          :last_name => @account.last_name,
          :address1 => @user.b_address1,
          :zip => @user.b_zip,
          :country => @user.b_country,
          :city => "none",
          :state => "none",
          :phone => @user.b_phone,
          :ip_address => ip)
    end

    return @account

  end


  def reload(*args) # spec_me cover_me heckle_me
    @name = nil
    super
  end

  def lock_workstreams? # spec_me cover_me heckle_me
    (self.usage_over_at && self.usage_over_at.advance(:days => -1 * Setting::WORKSTREAM_LOCK_THRESHOLD) > DateTime.now) || (self.trial_expired_at && self.trial_expired_at.advance(:days => -1 *  Setting::WORKSTREAM_LOCK_THRESHOLD) > DateTime.now)
  end

  #detects if usage is way over, or trial has expired for a while, and locks out private workstreams belonging to user
  def lock_workstreams # spec_me cover_me heckle_me
    if self.lock_workstreams?
      self.owned_projects.each {|p| p.lock unless p.is_public?}
    end
  end

  def unlock_workstreams # spec_me cover_me heckle_me
    unless self.lock_workstreams?
      self.owned_projects.each {|p| p.unlock unless p.is_public?}
    end
  end

  def usage_over? # spec_me cover_me heckle_me
    self.project_storage_total > self.plan.storage_max || self.private_project_total > self.plan.private_workstream_max || self.private_contributor_total > self.plan.contributor_max
  end

  #detects if usage is over, and sets date of going over
  def update_usage_over # spec_me cover_me heckle_me
    is_over = self.usage_over?

    self.lock_workstreams if is_over

    if is_over && !self.usage_over_at
      Notification.create :recipient_id => self.id,
                          :variation => 'usage_over',
                          :sender_id => User.sysadmin.id,
                          :source_id => self.id,
                          :source_type => "User"

      self.update_attribute(:usage_over_at, DateTime.now)
    end

    if !is_over && self.usage_over_at
      Notification.delete_all(:variation => 'usage_over', :source_id => self.id)
      self.update_attribute(:usage_over_at, nil)
      self.unlock_workstreams
    end

  end

  #detects if trial expired, and sets date of trial expiring
  def update_trial_expiration # spec_me cover_me heckle_me
    return if self.plan.free?

    if !self.trial_expires_on
      if self.trial_expired_at
        self.update_attribute(:trial_expired_at, nil)
        self.unlock_workstreams
      end
      return
    end

    if self.trial_expired_at
      self.lock_workstreams
      return
    end

    if DateTime.now > self.trial_expires_on
      Notification.create :recipient_id => self.id,
                          :variation => 'trial_expired',
                          :sender_id => User.sysadmin.id,
                          :source_id => self.id,
                          :source_type => "User"

      self.update_attribute(:trial_expired_at, DateTime.now)
    end
  end

  def identity_url=(url) # spec_me cover_me heckle_me
    if url.blank?
      write_attribute(:identity_url, '')
    else
      begin
        write_attribute(:identity_url, OpenIdAuthentication.normalize_identifier(url))
      rescue OpenIdAuthentication::InvalidOpenId
        # Invlaid url, don't save
      end
    end
    self.read_attribute(:identity_url)
  end

  def authenticate(password)
    if auth_source
      auth_source.authenticate(login, password)
    else
      self.class.hash_password(password) == hashed_password
    end
  end

  # Returns the user that matches provided login and password, or nil
  def self.authenticate(login, password)
    # Make sure no one can sign in with an empty password
    return if password.blank?
    user = find(:first, :conditions => ["login=?", login.downcase])
    if user
      return unless user.authenticate(password)
    else
      # user is not yet registered, try to authenticate with available sources
      attrs = AuthSource.authenticate(login, password)
      if attrs
        user = new(*attrs)
        user.login = login
        user.language = Setting.default_language
        user.reload if user.save
      end
    end
    user.update_attribute(:last_login_on, Time.now) if user && !user.new_record?
    user
  rescue => text
    raise text
  end

  # Returns the user who matches the given autologin +key+ or nil
  def self.try_to_autologin(key) # spec_me cover_me heckle_me
    tokens = Token.find_all_by_action_and_value('autologin', key)
    # Make sure there's only 1 token that matches the key
    if tokens.size == 1
      token = tokens.first
      if (token.created_at > Setting.autologin.to_i.day.ago) && token.user && token.user.active?
        token.user.update_attribute(:last_login_on, Time.now)
        token.user
      end
    end
  end

  # Return user's full name for display
  def name(formatter = nil) # spec_me cover_me heckle_me
    if formatter
      eval('"' + (USER_FORMATS[formatter] || USER_FORMATS[:firstname_lastname]) + '"').strip
    else
      @name ||= eval('"' + (USER_FORMATS[Setting.user_format] || USER_FORMATS[:firstname_lastname]) + '"').strip
    end
  end

  def active? # spec_me cover_me heckle_me
    self.status == STATUS_ACTIVE
  end

  def reactivate # spec_me cover_me heckle_me
    # TODO: don't use update_attribute, as it bypasses validations
    self.update_attribute(:status, User::STATUS_ACTIVE)
    newmail = []
    # TODO: get rid of this logic
    self.mail.split('.').each do |s|
      break if s == 'canceled'
      newmail.push(s)
    end
    newmail = newmail.join(".")
    # TODO: don't use update_attribute, as it bypasses validations
    self.update_attribute(:mail, newmail) if self.mail != newmail
  end

  def registered? # spec_me cover_me heckle_me
    self.status == STATUS_REGISTERED
  end

  def lock # spec_me cover_me heckle_me
    # TODO: don't use update_attribute, as it bypasses validations
    self.update_attribute(:status, STATUS_LOCKED)
  end

  def cancel # heckle_me
    self.update_attribute(:status, STATUS_CANCELED)
    # TODO: get rid of this, not sure why we change the email
    self.update_attribute(:mail, self.mail + ".canceled.#{rand(1000)}")
  end

  def cancel_account! # spec_me cover_me heckle_me
    cancel
  end

  def canceled?
    status == STATUS_CANCELED
  end

  def locked? # heckle_me
    self.status == STATUS_LOCKED
  end

  def check_password?(clear_password)
    User.hash_password(clear_password) == self.hashed_password
  end

  # Generate and set a random password.  Useful for automated user creation
  # Based on Token#generate_token_value
  #
  def random_password # spec_me cover_me heckle_me
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ''
    40.times { |i| password << chars[rand(chars.size-1)] }
    self.password = password
    self.password_confirmation = password
    self
  end

  def pref # spec_me cover_me heckle_me
    self.preference ||= UserPreference.new(:user => self)
  end

  def time_zone # spec_me cover_me heckle_me
    @time_zone ||= (self.pref.time_zone.blank? ? nil : ActiveSupport::TimeZone[self.pref.time_zone])
  end

  def wants_comments_in_reverse_order? # spec_me cover_me heckle_me
    self.pref[:comments_sorting] == 'desc'
  end

  # Return user's RSS key (a 40 chars long string), used to access feeds
  def rss_key # spec_me cover_me heckle_me
    token = self.rss_token || Token.create(:user => self, :action => 'feeds')
    token.value
  end

  # Return user's API key (a 40 chars long string), used to access the API
  def api_key # spec_me cover_me heckle_me
    token = self.api_token || Token.create(:user => self, :action => 'api')
    token.value
  end

  # Return an array of project ids for which the user has explicitly turned mail notifications on
  def notified_projects_ids # spec_me cover_me heckle_me
    @notified_projects_ids ||= memberships.select {|m| m.mail_notification?}.collect(&:project_id)
  end

  def notified_project_ids=(ids) # spec_me cover_me heckle_me
    Member.update_all("mail_notification = #{connection.quoted_false}", ['user_id = ?', id])
    Member.update_all("mail_notification = #{connection.quoted_true}", ['user_id = ? AND project_id IN (?)', id, ids]) if ids && !ids.empty?
    @notified_projects_ids = nil
    notified_projects_ids
  end

  def self.find_by_rss_key(key) # spec_me cover_me heckle_me
    token = Token.find_by_value(key)
    token && token.user.active? ? token.user : nil
  end

  def self.find_by_api_key(key) # spec_me cover_me heckle_me
    token = Token.find_by_action_and_value('api', key)
    token && token.user.active? ? token.user : nil
  end

  # Makes find_by_mail case-insensitive
  def self.find_by_mail(mail) # spec_me cover_me heckle_me
    find(:first, :conditions => ["LOWER(mail) = ?", mail.to_s.downcase])
  end

  # Makes find_by_login case-insensitive
  def self.find_by_login(login) # spec_me cover_me heckle_me
    find(:first, :conditions => ["LOWER(login) = ?", login.to_s.downcase])
  end

  def to_s # spec_me cover_me heckle_me
    name
  end

  # Returns the current day according to user's time zone
  def today # spec_me cover_me heckle_me
    if time_zone.nil?
      Date.today
    else
      Time.now.in_time_zone(time_zone).to_date
    end
  end

  def logged? # spec_me cover_me heckle_me
    true
  end

  def anonymous? # spec_me cover_me heckle_me
    !logged?
  end

  # Return user's roles for project
  def roles_for_project(child_project) # spec_me cover_me heckle_me
    project = child_project.root
    roles = []
    # No role on archived projects
    return roles unless project && project.active?
    if logged?
      # Find project membership
      membership = memberships.detect {|m| m.project_id == project.id}
      if membership
        roles = membership.roles
      else
        @role_non_member ||= Role.non_member
        roles << @role_non_member
      end
    else
      @role_anonymous ||= Role.anonymous
      roles << @role_anonymous
    end
    roles
  end

  # Return true if the user is a communitymember of project
  def community_member_of?(project) # spec_me cover_me heckle_me
    !roles_for_project(project.root).detect {|role| role.community_member?}.nil?
  end

  # Return true if the user is an enterprise member of project
  def enterprise_member_of?(project) # spec_me cover_me heckle_me
    !roles_for_project(project.root).detect {|role| role.enterprise_member?}.nil?
  end

  # Return true if the user is admin of project
   def admin_of?(project) # spec_me cover_me heckle_me
     !roles_for_project(project.root).detect {|role| role.admin?}.nil?
   end


  # Return true if the user is a member of project
  def member_of?(project) # spec_me cover_me heckle_me
    !roles_for_project(project.root).detect {|role| role.member?}.nil?
  end

  # Return true if the user is a core member of project
   def core_member_of?(project) # spec_me cover_me heckle_me
     !roles_for_project(project.root).detect {|role| role.core_member?}.nil?
   end

   # Return true if the user is a contributor of project
  def contributor_of?(project) # spec_me cover_me heckle_me
     !roles_for_project(project.root).detect {|role| role.contributor?}.nil?
  end

  # Return true if the user's votes are binding
  def binding_voter_of?(project) # spec_me cover_me heckle_me
    !roles_for_project(project.root).detect {|role| role.binding_member?}.nil?
  end

  # Return true if the user's votes are binding for this motion
  def binding_voter_of_motion?(motion) # spec_me cover_me heckle_me
    position_for(motion.project) <= motion.binding_level.to_f
  end

  # Return true if the user is allowed to see motion
  def allowed_to_see_motion?(motion) # spec_me cover_me heckle_me
    return true if User.current == User.sysadmin
    position_for(motion.project) <= motion.visibility_level.to_f
  end

  # Return true if the user is a allowed to see project
  #If root project is public, then we check that user has been given explicit clearance
  #If root project is private, then all contributors have access
  def allowed_to_see_project?(project) # spec_me cover_me heckle_me
    return true if project.is_public?
    if project.root.is_public?
      roles_for_project(project).detect {|role| role.binding_member? || role.clearance?}
    else
      roles_for_project(project).detect {|role| role.community_member?}
    end
  end


  # Returns position level for user's role in project's enterprise (the lower number, the higher in heirarchy the user)
  def position_for(project) # spec_me cover_me heckle_me
    roles_for_project(project.root).sort{|x,y| x.position <=> y.position}.first.position
  end

  # Return true if the user is allowed to do the specified action on project
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action, project, options={}) # spec_me cover_me heckle_me
    if project
      # No action allowed on archived projects except unarchive
      return false unless project.active? || project.locked? || (action.class.to_s == "Hash" && action[:action] == "unarchive")
      # No action allowed on disabled modules
      return false unless project.allows_to?(action)
      # Admin users are authorized for anything else
      return true if admin?

      # #Check if user is a citizen of the enterprise, and the citizen role is allowed to take that action
      # return true if citizen_of?(project) && Role.citizen.allowed_to?(action)
      roles = roles_for_project(project)
      return false unless roles
      roles.detect {|role| role.allowed_to?(action)} && allowed_to_see_project?(project)
    elsif options[:global]
      # Admin users are always authorized
      return true if admin?
      # authorize if user has at least one role that has this permission
      roles = memberships.collect {|m| m.roles}.flatten.uniq
      roles.detect {|r| r.allowed_to?(action)} || (self.logged? ? Role.non_member.allowed_to?(action) : Role.anonymous.allowed_to?(action))
    else
      admin?
    end
  end

  #Adds current user to core team of project
  def add_as_core(project, options={}) # spec_me cover_me heckle_me
    #Add as core member of current project
    add_to_project project, Role.core_member
    drop_from_project(project, Role.contributor)
    drop_from_project(project, Role.member)
  end

  def add_as_member(project, options={}) # spec_me cover_me heckle_me
    #Add as core member of current project
    add_to_project project, Role.member
    drop_from_project(project, Role.contributor)
    drop_from_project(project, Role.core_member)
  end


  #Adds current user as contributor of project
  def add_as_contributor(project, options={}) # spec_me cover_me heckle_me
      add_to_project project, Role.contributor
      drop_from_project(project, Role.core_member)
      drop_from_project(project, Role.member)
  end

  #Adds current user as contributor of project if they aren't a binding member
  def add_as_contributor_if_new(project, options={}) # spec_me cover_me heckle_me
      add_as_contributor project unless self.binding_voter_of?(project)
  end

  #Adds user to that project as that role
  def add_to_project(project, role, options={}) # spec_me cover_me heckle_me
    project = project.root if role.enterprise_member?
    m = Member.find(:first, :conditions => {:user_id => id, :project_id => project}) #First we see if user is already a member of this project
    if m.nil?
      #User isn't a member let's create a membership
      member_role = Role.find(:first, :conditions => {:id => role.id})
      m = Member.new(:user => self, :roles => [member_role])
      p = Project.find(project)
      result = p.all_members << m
    else
      #User is already a member, we just add a role (but make sure role doesn't exist already)
      MemberRole.create! :member_id => m.id, :role_id => role.id if MemberRole.first(:conditions => {:member_id => m.id, :role_id => role.id}) == nil
    end
  end

  #Drops user from role of that project
  def drop_from_project(project, role, options={}) # spec_me cover_me heckle_me
    m = Member.find(:first, :conditions => {:user_id => id, :project_id => project}) #First we see if user is already a member of this project
    m.member_roles.each {|r|
      r.destroy if r.role_id == role.id
    } unless m.nil?
  end

  #Drops current user from core team of project
  def drop_from_core(project, options={}) # spec_me cover_me heckle_me
    drop_from_project project, Role::BUILTIN_CORE_MEMBER
  end

  def self.current=(user) # spec_me cover_me heckle_me
    # TODO: stop relying on this and remove it -- too much state
    Thread.current[:user] = user
  end

  def self.current # spec_me cover_me heckle_me
    Thread.current[:user] ||= User.anonymous
  end

  # Returns the anonymous user.  If the anonymous user does not exist, it is created.  There can be only
  # one anonymous user per database.
  def self.anonymous # spec_me cover_me heckle_me
    anonymous_user = AnonymousUser.find(:first)
    if anonymous_user.nil?
      anonymous_user = AnonymousUser.create(:lastname => 'Anonymous', :firstname => '', :mail => '', :login => '', :status => 0)
      raise 'Unable to create the anonymous user.' if anonymous_user.new_record?
    end
    anonymous_user
  end

  def self.sysadmin # spec_me cover_me heckle_me
    User.find_by_login("admin")
  end

  #total owned public projects
  def public_project_total # spec_me cover_me heckle_me
    self.owned_projects.find_all{|p| p.is_public  && (p.active? || p.locked?) }.length
  end

  def private_project_total # spec_me cover_me heckle_me
    self.owned_projects.find_all{|p| !p.is_public && (p.active? || p.locked?) }.length
  end

  def public_contributor_total # spec_me cover_me heckle_me
    @all_users = []
    self.owned_projects.find_all{|p| p.is_public && (p.active? || p.locked?) }.each {|p| @all_users = @all_users | p.all_members.collect{|m| m.user_id}}
    @all_users.length
  end

  def private_contributor_total # spec_me cover_me heckle_me
    @all_users = []
    self.owned_projects.find_all{|p| !p.is_public && (p.active? || p.locked?) }.each {|p| @all_users = @all_users | p.all_members.collect{|m| m.user_id}}
    @all_users.length
  end

  def project_storage_total # spec_me cover_me heckle_me
    self.owned_projects.inject(0){|sum,item| sum + item.storage}
  end

  #projects user belongs to but doesnt own
  def belongs_to_projects # spec_me cover_me heckle_me
    self.projects.does_not_belong_to(self.id)
  end

  #returns list of recent projects with a max count
  def recent_projects(max = 10) # spec_me cover_me heckle_me
    project_ids = ActivityStream.find_by_sql("SELECT project_id FROM activity_streams WHERE actor_id = #{self.id} AND updated_at > '#{Time.now.advance :days => (Setting::DAYS_FOR_RECENT_PROJECTS * -1)}' GROUP BY project_id ORDER BY MAX(updated_at) DESC LIMIT #{max}").collect {|a| a.project_id}.join(",")
    return [] unless project_ids.length > 0
    Project.find(:all, :conditions => "id in (#{project_ids})")
  end

  #returns list of recent items with a max count of 10
  def recent_items(max = 10) # spec_me cover_me heckle_me
    item_ids = ActivityStream.find_by_sql("SELECT object_id FROM activity_streams WHERE actor_id = #{self.id} AND object_type = 'Issue' AND object_id is not null GROUP BY object_id ORDER BY MAX(updated_at) DESC LIMIT #{max}").collect {|a| a["object_id"]}.join(",")
    return [] if item_ids.empty?
    Issue.find(:all, :conditions => "id in (#{item_ids})",
              :include => [:project, :tracker ],
              :order => "#{Issue.table_name}.updated_at DESC")
  end

  def self.find_available_login(array) # spec_me cover_me heckle_me
    array.each do |string|
      string = string.gsub(/ /,"_").gsub(/'|\"|<|>/,"_")
      # TODO: this can probably be optimized into a single database query
      return string unless find_by_login(string)
    end
    nil
  end

  def delete_autologin_tokens # spec_me cover_me heckle_me
    tokens.find_all_by_action('autologin').collect(&:delete)
  end

  def activate # spec_me cover_me heckle_me
    self.status = STATUS_ACTIVE
  end

  def fullname=(fullname) # spec_me cover_me heckle_me
    self.firstname, self.lastname = fullname.split if fullname
  end

  protected

  def validate # spec_me cover_me heckle_me
    # Password length validation based on setting
    if !password.nil? && password.size < Setting.password_min_length.to_i
      errors.add(:password, :too_short, :count => Setting.password_min_length.to_i)
    end
  end

  private

  # Return password digest
  def self.hash_password(clear_password)
    # TODO: somehow switch this out, SHA is not recommended for passwords
    Digest::SHA1.hexdigest(clear_password || "")
  end

end

class AnonymousUser < User

  def validate_on_create # spec_me cover_me heckle_me
    # There should be only one AnonymousUser in the database
    errors.add_to_base 'An anonymous user already exists.' if AnonymousUser.find(:first)
  end

  # Overrides a few properties
  def logged?; false end # spec_me cover_me heckle_me
  def admin; false end # spec_me cover_me heckle_me
  def name(*args); I18n.t(:label_user_anonymous) end # spec_me cover_me heckle_me
  def mail; nil end # spec_me cover_me heckle_me
  def time_zone; nil end # spec_me cover_me heckle_me
  def rss_key; nil end # spec_me cover_me heckle_me
  def delete_autologin_tokens; nil end # spec_me cover_me heckle_me

end
