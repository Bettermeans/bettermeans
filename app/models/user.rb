# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#


require "digest/sha1"

class User < Principal

  # Account statuses
  STATUS_ANONYMOUS  = 0
  STATUS_ACTIVE     = 1
  STATUS_REGISTERED = 2
  STATUS_LOCKED     = 3
  
  USER_FORMATS = {
    :firstname_lastname => '#{firstname} #{lastname}',
    :firstname => '#{firstname}',
    :lastname_firstname => '#{lastname} #{firstname}',
    :lastname_coma_firstname => '#{lastname}, #{firstname}',
    :username => '#{login}'
  }

  has_and_belongs_to_many :groups, :after_add => Proc.new {|user, group| group.user_added(user)},
                                   :after_remove => Proc.new {|user, group| group.user_removed(user)}
  # has_many :issue_categories, :foreign_key => 'assigned_to_id', :dependent => :nullify
  has_many :changesets, :dependent => :nullify
  has_one :preference, :dependent => :destroy, :class_name => 'UserPreference'
  has_one :rss_token, :dependent => :destroy, :class_name => 'Token', :conditions => "action='feeds'"
  has_one :api_token, :dependent => :destroy, :class_name => 'Token', :conditions => "action='api'"
  belongs_to :auth_source
  
  has_many :commit_requests, :dependent => :delete_all
  has_many :notifications, :foreign_key => 'recipient_id', :dependent => :delete_all
  
  has_many :shares, :dependent => :nullify
  has_many :credits, :foreign_key => :owner_id, :dependent => :delete_all
  has_many :issue_votes, :dependent => :delete_all
  has_many :authored_todos, :class_name => 'Todo', :foreign_key => 'author_id', :dependent => :nullify
  has_many :owned_todos, :class_name => 'Todo', :foreign_key => 'owner_id', :dependent => :nullify
  
  has_many :outgoing_ratings, :class_name => 'RetroRating', :foreign_key => 'rater_id'
  has_many :incoming_ratings, :class_name => 'RetroRating', :foreign_key => 'ratee_id'
  has_many :credit_disributions
    
  # Active non-anonymous users scope
  named_scope :active, :conditions => "#{User.table_name}.status = #{STATUS_ACTIVE}"
  
  has_karma :issues
  has_karma :journals
  has_karma :messages
  
  acts_as_voter #for vote_fu plugin
  
  acts_as_customizable
  
  has_private_messages :class_name => "Mail"
  
  attr_accessor :password, :password_confirmation
  attr_accessor :last_before_login_on
  # Prevents unauthorized assignments
  attr_protected :login, :admin, :password, :password_confirmation, :hashed_password, :group_ids
	
  validates_presence_of :login, :firstname, :lastname, :mail, :if => Proc.new { |user| !user.is_a?(AnonymousUser) }
  validates_uniqueness_of :login, :if => Proc.new { |user| !user.login.blank? }
  validates_uniqueness_of :mail, :if => Proc.new { |user| !user.mail.blank? }, :case_sensitive => false
  # Login must contain lettres, numbers, underscores only
  validates_format_of :login, :with => /^[a-z0-9_\-@\.]*$/i
  validates_length_of :login, :maximum => 30
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i
  validates_length_of :firstname, :lastname, :maximum => 30
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_nil => true
  validates_length_of :mail, :maximum => 60, :allow_nil => true
  validates_confirmation_of :password, :allow_nil => true

  def before_create
    self.mail_notification = false
    true
  end
  
  def before_save
    # update hashed_password if password was set
    self.hashed_password = User.hash_password(self.password) if self.password
  end
  
  def reload(*args)
    @name = nil
    super
  end
  
  def identity_url=(url)
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
  
  # Returns the user that matches provided login and password, or nil
  def self.try_to_login(login, password)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?
    user = find(:first, :conditions => ["login=?", login])
    if user
      # user is already in local database
      return nil if !user.active?
      if user.auth_source
        # user has an external authentication method
        return nil unless user.auth_source.authenticate(login, password)
      else
        # authentication with local password
        return nil unless User.hash_password(password) == user.hashed_password        
      end
    else
      # user is not yet registered, try to authenticate with available sources
      attrs = AuthSource.authenticate(login, password)
      if attrs
        user = new(*attrs)
        user.login = login
        user.language = Setting.default_language
        if user.save
          user.reload
          logger.info("User '#{user.login}' created from the LDAP") if logger
        end
      end
    end    
    user.update_attribute(:last_login_on, Time.now) if user && !user.new_record?
    user
  rescue => text
    raise text
  end
  
  # Returns the user who matches the given autologin +key+ or nil
  def self.try_to_autologin(key)
    tokens = Token.find_all_by_action_and_value('autologin', key)
    # Make sure there's only 1 token that matches the key
    if tokens.size == 1
      token = tokens.first
      if (token.created_on > Setting.autologin.to_i.day.ago) && token.user && token.user.active?
        token.user.update_attribute(:last_login_on, Time.now)
        token.user
      end
    end
  end
	
  # Return user's full name for display
  def name(formatter = nil)
    if formatter
      eval('"' + (USER_FORMATS[formatter] || USER_FORMATS[:firstname_lastname]) + '"')
    else
      @name ||= eval('"' + (USER_FORMATS[Setting.user_format] || USER_FORMATS[:firstname_lastname]) + '"')
    end
  end
  
  def active?
    self.status == STATUS_ACTIVE
  end

  def registered?
    self.status == STATUS_REGISTERED
  end
    
  def locked?
    self.status == STATUS_LOCKED
  end

  def check_password?(clear_password)
    User.hash_password(clear_password) == self.hashed_password
  end

  # Generate and set a random password.  Useful for automated user creation
  # Based on Token#generate_token_value
  #
  def random_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ''
    40.times { |i| password << chars[rand(chars.size-1)] }
    self.password = password
    self.password_confirmation = password
    self
  end
  
  def pref
    self.preference ||= UserPreference.new(:user => self)
  end
  
  def time_zone
    @time_zone ||= (self.pref.time_zone.blank? ? nil : ActiveSupport::TimeZone[self.pref.time_zone])
  end
  
  def wants_comments_in_reverse_order?
    self.pref[:comments_sorting] == 'desc'
  end
  
  # Return user's RSS key (a 40 chars long string), used to access feeds
  def rss_key
    token = self.rss_token || Token.create(:user => self, :action => 'feeds')
    token.value
  end

  # Return user's API key (a 40 chars long string), used to access the API
  def api_key
    token = self.api_token || Token.create(:user => self, :action => 'api')
    token.value
  end
  
  # Return an array of project ids for which the user has explicitly turned mail notifications on
  def notified_projects_ids
    @notified_projects_ids ||= memberships.select {|m| m.mail_notification?}.collect(&:project_id)
  end
  
  def notified_project_ids=(ids)
    Member.update_all("mail_notification = #{connection.quoted_false}", ['user_id = ?', id])
    Member.update_all("mail_notification = #{connection.quoted_true}", ['user_id = ? AND project_id IN (?)', id, ids]) if ids && !ids.empty?
    @notified_projects_ids = nil
    notified_projects_ids
  end
  
  def self.find_by_rss_key(key)
    token = Token.find_by_value(key)
    token && token.user.active? ? token.user : nil
  end
  
  def self.find_by_api_key(key)
    token = Token.find_by_action_and_value('api', key)
    token && token.user.active? ? token.user : nil
  end
  
  # Makes find_by_mail case-insensitive
  def self.find_by_mail(mail)
    find(:first, :conditions => ["LOWER(mail) = ?", mail.to_s.downcase])
  end
  
  def to_s
    name
  end
  
  # Returns the current day according to user's time zone
  def today
    if time_zone.nil?
      Date.today
    else
      Time.now.in_time_zone(time_zone).to_date
    end
  end
  
  def logged?
    true
  end
  
  def anonymous?
    !logged?
  end
  
  # Return user's roles for project
  def roles_for_project(child_project)
    project = child_project.root
    roles = []
    # No role on archived projects
    return roles unless child_project && child_project.active?
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
  
  # Return true if the user is a member of project
  def member_of?(project)
    !roles_for_project(project.root).detect {|role| role.member?}.nil?
  end
  
  # Return true if the user is a core member of project
   def core_member_of?(project)
     !roles_for_project(project.root).detect {|role| role.core_member?}.nil?
   end
  
   # Return true if the user is a contributor of project
  def contributor_of?(project)
     !roles_for_project(project.root).detect {|role| role.contributor?}.nil?
  end
  
  # Return true if the user's votes are binding
  def binding_voter_of?(project)
    !roles_for_project(project.root).detect {|role| role.binding_member?}.nil?
  end

  # Return true if the user's votes are binding for this motion
  def binding_voter_of_motion?(motion)
    position_for(motion.project) <= motion.binding_level
  end
  
  # Return true if the user is allowed to see motion
  def allowed_to_see_motion?(motion)
    position_for(motion.project) <= motion.visibility_level
  end  
  
  # Returns position level for user's role in project's enterprise (the lower number, the higher in heirarchy the user)
  def position_for(project)
    roles_for_project(project.root).first.position
  end
    
  # Return true if the user is allowed to do the specified action on project
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action, project, options={})
    if project
      # No action allowed on archived projects
      return false unless project.active?
      # No action allowed on disabled modules
      return false unless project.allows_to?(action)
      # Admin users are authorized for anything else
      return true if admin?
      
      # #Check if user is a citizen of the enterprise, and the citizen role is allowed to take that action
      # return true if citizen_of?(project) && Role.citizen.allowed_to?(action)
      
      
      roles = roles_for_project(project)
      return false unless roles
      roles.detect {|role| (project.is_public? || role.community_member?) && role.allowed_to?(action)}
      
    elsif options[:global]
      # Admin users are always authorized
      return true if admin?
      
      # authorize if user has at least one role that has this permission
      roles = memberships.collect {|m| m.roles}.flatten.uniq
      roles.detect {|r| r.allowed_to?(action)} || (self.logged? ? Role.non_member.allowed_to?(action) : Role.anonymous.allowed_to?(action))
    else
      false
    end
  end
  
  #Total team points for this user for this project
  def team_points_for(project, options={})
    TeamPoint.total(self,project)
  end
  
  #Adds current user to core team of project
  def add_to_core(project, options={})
    if project.eligible_for_core?(self)
      #Add as core member of current project
      add_to_project project, Role::BUILTIN_CORE_MEMBER       
      puts "core member: #{self.core_member_of?(project)}"
      #Add as contributor to parent project, unless they're already core
      add_to_project project.parent, Role::BUILTIN_CONTRIBUTOR unless project.parent.nil? || self.core_member_of?(project.parent)
    end
  end
  
  #Adds user to that project as that role
  def add_to_project(project, role_id, options={})
    m = Member.find(:first, :conditions => {:user_id => id, :project_id => project}) #First we see if user is already a member of this project
    if m.nil? 
      #User isn't a member let's create a membership
      member_role = Role.find(:first, :conditions => {:id => role_id})
      m = Member.new(:user => self, :roles => [member_role])
      p = Project.find(project)
      result = p.members << m
    else
      #User is already a member, we just add a role (but make sure role doesn't exist already)
      MemberRole.create! :member_id => m.id, :role_id => role_id if MemberRole.first(:conditions => {:member_id => m.id, :role_id => role_id}) == nil
    end
  end
  
  #Drops user from role of that project
  def drop_from_project(project, role_id, options={})
    m = Member.find(:first, :conditions => {:user_id => id, :project_id => project}) #First we see if user is already a member of this project
    m.member_roles.each {|r|
      r.destroy if r.role_id == role_id
    } unless m.nil?
  end
  
  #Drops current user from core team of project
  def drop_from_core(project, options={})
    drop_from_project project, Role::BUILTIN_CORE_MEMBER
  end
  
  def self.current=(user)
    @current_user = user
  end
  
  def self.current
    @current_user ||= User.anonymous
  end
  
  # Returns the anonymous user.  If the anonymous user does not exist, it is created.  There can be only
  # one anonymous user per database.
  def self.anonymous
    anonymous_user = AnonymousUser.find(:first)
    if anonymous_user.nil?
      anonymous_user = AnonymousUser.create(:lastname => 'Anonymous', :firstname => '', :mail => '', :login => '', :status => 0)
      raise 'Unable to create the anonymous user.' if anonymous_user.new_record?
    end
    anonymous_user
  end
  
  def self.sysadmin
    User.find(:first,:conditions => {:login => "admin"})
  end
  
  protected
  
  def validate
    # Password length validation based on setting
    if !password.nil? && password.size < Setting.password_min_length.to_i
      errors.add(:password, :too_short, :count => Setting.password_min_length.to_i)
    end
  end
  
  private
    
  # Return password digest
  def self.hash_password(clear_password)
    Digest::SHA1.hexdigest(clear_password || "")
  end
end

class AnonymousUser < User
  
  def validate_on_create
    # There should be only one AnonymousUser in the database
    errors.add_to_base 'An anonymous user already exists.' if AnonymousUser.find(:first)
  end
  
  def available_custom_fields
    []
  end
  
  # Overrides a few properties
  def logged?; false end
  def admin; false end
  def name(*args); I18n.t(:label_user_anonymous) end
  def mail; nil end
  def time_zone; nil end
  def rss_key; nil end
end


# == Schema Information
#
# Table name: users
#
#  id                :integer         not null, primary key
#  login             :string(30)      default(""), not null
#  hashed_password   :string(40)      default(""), not null
#  firstname         :string(30)      default(""), not null
#  lastname          :string(30)      default(""), not null
#  mail              :string(60)      default(""), not null
#  mail_notification :boolean         default(TRUE), not null
#  admin             :boolean         default(FALSE), not null
#  status            :integer         default(1), not null
#  last_login_on     :datetime
#  language          :string(5)       default("")
#  auth_source_id    :integer
#  created_on        :datetime
#  updated_on        :datetime
#  type              :string(255)
#  identity_url      :string(255)
#

