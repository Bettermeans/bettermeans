# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Project < ActiveRecord::Base
  
  # Project statuses
  STATUS_ACTIVE     = 1
  STATUS_ARCHIVED   = 9
  
  
  
  
  belongs_to :enterprise                        
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  # Specific overidden Activities
  has_many :all_members,:class_name => 'Member', 
                        :include => [:user, :roles], :conditions => "#{User.table_name}.status=#{User::STATUS_ACTIVE}",
                        :order => "firstname ASC"
                        
  has_many :administrators, :class_name => 'Member', 
                          :include => [:user,:roles], 
                          :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_ADMINISTRATOR}",
                           :order => "firstname ASC"

  has_many :core_members, :class_name => 'Member', 
                          :include => [:user,:roles], 
                          :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_CORE_MEMBER}",
                           :order => "firstname ASC"


  has_many :members, :class_name => 'Member', 
                           :include => [:user,:roles], 
                           :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_MEMBER}",
                            :order => "firstname ASC",
                            :dependent => :destroy

  has_many :board_members, :class_name => 'Member', 
                            :include => [:user,:roles], 
                            :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_BOARD}",
                             :order => "firstname ASC"

  has_many :contributors, :class_name => 'Member', 
                          :include => [:user,:roles], 
                          :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_CONTRIBUTOR}",
                           :order => "firstname ASC"


   has_many :binding_members, :class_name => 'Member', 
                           :include => [:user,:roles], 
                           :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_MEMBER} OR #{Role.table_name}.builtin=#{Role::BUILTIN_CORE_MEMBER} OR #{Role.table_name}.builtin=#{Role::BUILTIN_BOARD} OR #{Role.table_name}.builtin=#{Role::BUILTIN_ADMINISTRATOR}",
                            :order => "firstname ASC"

  has_many :enterprise_members, :class_name => 'Member', 
                          :include => [:user,:roles], 
                          :conditions => "#{Role.table_name}.builtin=#{Role::BUILTIN_CONTRIBUTOR} OR #{Role.table_name}.builtin=#{Role::BUILTIN_MEMBER} OR #{Role.table_name}.builtin=#{Role::BUILTIN_CORE_MEMBER} OR #{Role.table_name}.builtin=#{Role::BUILTIN_BOARD} OR #{Role.table_name}.builtin=#{Role::BUILTIN_ADMINISTRATOR}",
                           :order => "firstname ASC"


  has_many :member_users, :class_name => 'Member', 
                               :include => :user,
                               :conditions => "#{User.table_name}.status=#{User::STATUS_ACTIVE}"
                               
  has_many :users, :through => :all_members

  has_many :credit_distributions, :dependent => :delete_all
  has_many :enabled_modules, :dependent => :delete_all
  has_and_belongs_to_many :trackers, :order => "#{Tracker.table_name}.position"
  has_many :issues, :dependent => :destroy, :order => "#{Issue.table_name}.created_at DESC", :include => [:status, :tracker]
  has_many :issue_votes, :through => :issues
  has_many :issue_changes, :through => :issues, :source => :journals
  has_many :queries, :dependent => :delete_all
  has_many :documents, :dependent => :destroy
  has_many :news, :dependent => :delete_all, :include => :author
  has_many :boards, :dependent => :destroy, :order => "position ASC"
  has_many :messages, :through => :boards
  has_one :wiki, :dependent => :destroy
  has_many :shares, :dependent => :delete_all
  has_many :credits, :dependent => :delete_all, :order => 'created_at ASC'
  has_many :retros, :dependent => :delete_all
  has_many :reputations, :dependent => :delete_all
  has_many :motions, :dependent => :delete_all
  has_many :hourly_types, :dependent => :delete_all
  has_many :activity_streams, :dependent => :delete_all #TODO: include sub workstreams here!
  has_many :invitations, :dependent => :delete_all

  acts_as_nested_set :order => 'name', :dependent => :destroy
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  acts_as_searchable :columns => ['name', 'description'], :project_key => 'id', :permission => nil
  acts_as_event :title => Proc.new {|o| "#{l(:label_project)}: #{o.name}"},
                :url => Proc.new {|o| {:controller => 'projects', :action => 'show', :id => o.id}},
                :author => nil

  acts_as_fleximage do
    begin
      require_image false
      if RAILS_ENV == 'production'
        s3_bucket 'bettermeans_workstream_logos'
      else
        image_directory '/public/help'
      end
      preprocess_image do |image|
        image.resize '200x600'
      end 
    rescue
    end
  end 

  attr_protected :status, :enabled_module_names
  
  validates_presence_of :name, :identifier
  validates_uniqueness_of :identifier
  validates_associated :wiki
  validates_length_of :name, :maximum => 50
  validates_length_of :homepage, :maximum => 255
  validates_length_of :identifier, :in => 1..20
  # donwcase letters, digits, dashes but not digits only
  # validates_format_of :identifier, :with => /^(?!\d+$)[a-z0-9\-]*$/, :if => Proc.new { |p| p.identifier_changed? }
  # reserved words
  validates_exclusion_of :identifier, :in => %w( new )

  before_destroy :delete_all_members

  named_scope :has_module, lambda { |mod| { :conditions => ["#{Project.table_name}.id IN (SELECT em.project_id FROM #{EnabledModule.table_name} em WHERE em.name=?)", mod.to_s] } }
  named_scope :active, { :conditions => "#{Project.table_name}.status = #{STATUS_ACTIVE}"}
  named_scope :all_public, { :conditions => { :is_public => true } }
  named_scope :visible, lambda { { :conditions => Project.visible_by(User.current) } }
  named_scope :all_roots, {:conditions => "parent_id is null"}
  named_scope :all_children, {:conditions => "parent_id is not null"}
  named_scope :does_not_belong_to, lambda {|id| 
    {:conditions => ["owner_id <> :s", {:s => id}],
     :order => 'name'
    }
  } 
  
  reportable :daily_new_projects, :aggregation => :count, :limit => 14
  reportable :weekly_new_projects, :aggregation => :count, :grouping => :week, :limit => 20
  
  
  def project_id
    self.id
  end
  
  def graph_data
    valid_kids = children.select{|c| c.active?}
    if valid_kids.size > 0
      mychildren = valid_kids.collect{ |node|  node.graph_data }
    else
      mychildren = []
    end
    diameter = issues.length**0.5/3.142*6
    { :id => self.identifier, :name => name, :children => mychildren, :data => {:$dim => diameter,:$angularWidth => diameter, :$color => '#fdd13d' } }
  end
  
  #returns array of project ids that are children of this project. includes id of current project
  def sub_project_array
    array = [self.id]
    self.children.each do |child|
      array += child.sub_project_array
    end
    array
  end
  
  #returns array of project ids that are children of this project. includes id of current project that are visible to user
  def sub_project_array_visible_to(user)
    if self.visible_to(user) 
      array = [self.id]
    else
      array = []
    end
    
    self.children.each do |child|
      array += child.sub_project_array_visible_to(user)
    end
    array
  end
  

  def graph_data2
    valid_kids = children.select{|c| c.active?}
    if valid_kids.size > 0
      mychildren = valid_kids.collect{ |node|  node.graph_data2 }
    else
      mychildren = []
    end
    diameter = issues.length**0.5/3.142*3
    { :levelDistance => issues.length,:id => self.identifier, :name => name, :children => mychildren, :data => {:$dim => diameter,:$angularWidth => diameter, :$color => '#fdd13d' } }
  end
  
  def identifier=(identifier)
    super unless identifier_frozen?
  end
  
  def identifier_frozen?
    errors[:identifier].nil? && !(new_record? || identifier.blank?)
  end

  # returns latest created projects
  # non public projects will be returned only if user is a member of those
  def self.latest(user=nil, count=10, root=false,offset=0)
    if root
      all_roots.find(:all, :limit => count, :conditions => visible_by(user), :order => "created_at DESC", :offset => offset)	
    else
      all_children.find(:all, :limit => count, :conditions => visible_by(user), :order => "created_at DESC", :offset => offset)	
    end
  end	
  
  # returns most active projects
  # non public projects will be returned only if user is a member of those
  def self.most_active(user=nil, count=10, root=false, offset=0)
    if root
      all_roots.find(:all, :limit => count, :conditions => visible_by(user), :order => "activity_total DESC", :offset => offset)	
    else
      all_children.find(:all, :limit => count, :conditions => visible_by(user), :order => "activity_total DESC", :offset => offset)	
    end
  end	
  
  
  #Returns true if project is visible by user
  def visible_to(user)
    return true if user.admin?
    return false unless active?
    return true if is_public
    return true if user.allowed_to_see_project?(self)
    return false
  end
  
  # Returns a SQL :conditions string used to find all active projects for the specified user.
  #
  # Examples:
  #     Projects.visible_by(admin)        => "projects.status = 1"
  #     Projects.visible_by(normal_user)  => "projects.status = 1 AND projects.is_public = 1"
  def self.visible_by(user=nil)
    user ||= User.current
    if user && user.admin?
      return "#{Project.table_name}.status=#{Project::STATUS_ACTIVE}"
    elsif user && user.memberships.any?
      return "#{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND (#{Project.table_name}.is_public = #{connection.quoted_true} or #{Project.table_name}.id IN (#{user.memberships.collect{|m| m.project_id}.join(',')}))"
    else
      return "#{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Project.table_name}.is_public = #{connection.quoted_true}"
    end
  end
  
  def fetch_credits(with_subprojects)
    with_subprojects ||= 'true'
    if with_subprojects == 'true'
      conditions = {}
      conditions[:project_id] = self.sub_project_array
      Credit.all(:conditions => conditions, :order => 'created_at ASC')
    else
      self.credits
    end
  end
  
  
  def self.allowed_to_condition(user, permission, options={})
    statements = []
    base_statement = "#{Project.table_name}.status=#{Project::STATUS_ACTIVE}"
    if perm = Redmine::AccessControl.permission(permission)
      unless perm.project_module.nil?
        # If the permission belongs to a project module, make sure the module is enabled
        base_statement << " AND #{Project.table_name}.id IN (SELECT em.project_id FROM #{EnabledModule.table_name} em WHERE em.name='#{perm.project_module}')"
      end
    end
    if options[:project]
      project_statement = "#{Project.table_name}.id = #{options[:project].id}"
      project_statement << " OR (#{Project.table_name}.lft > #{options[:project].lft} AND #{Project.table_name}.rgt < #{options[:project].rgt})" if options[:with_subprojects]
      base_statement = "(#{project_statement}) AND (#{base_statement})"
    end
    if user.admin?
      # no restriction
    else
      statements << "1=0"
      if user.logged?
        if Role.non_member.allowed_to?(permission) && !options[:member]
          statements << "#{Project.table_name}.is_public = #{connection.quoted_true}"
        end
        allowed_project_ids = user.memberships.select {|m| m.roles.detect {|role| role.allowed_to?(permission)}}.collect {|m| m.project_id}
        statements << "#{Project.table_name}.id IN (#{allowed_project_ids.join(',')})" if allowed_project_ids.any?
      else
        if Role.anonymous.allowed_to?(permission) && !options[:member]
          # anonymous user allowed on public project
          statements << "#{Project.table_name}.is_public = #{connection.quoted_true}"
        end 
      end
    end
    statements.empty? ? base_statement : "((#{base_statement}) AND (#{statements.join(' OR ')}))"
  end

  # Returns the Systemwide and project specific activities
  def activities(include_inactive=false)
    if include_inactive
      return all_activities
    else
      return active_activities
    end
  end

  # Returns a :conditions SQL string that can be used to find the issues associated with this project.
  #
  # Examples:
  #   project.project_condition(true)  => "(projects.id = 1 OR (projects.lft > 1 AND projects.rgt < 10))"
  #   project.project_condition(false) => "projects.id = 1"
  def project_condition(with_subprojects)
    cond = "#{Project.table_name}.id = #{id}"
    cond = "(#{cond} OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt}))" if with_subprojects
    cond
  end
  
  def self.find(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      project = find_by_identifier(*args)
      raise ActiveRecord::RecordNotFound, "Couldn't find Project with identifier=#{args.first}" if project.nil?
      project
    else
      super
    end
  end
 
  # def to_param
  #   # id is used for projects with a numeric identifier (compatibility)
  #   @to_param ||= (identifier.to_s =~ %r{^\d*$} ? id : identifier)
  # end
  
  def active?
    self.status == STATUS_ACTIVE
  end
  
  def enterprise?
    self.parent_id.nil?
  end
  
  # Archives the project and its descendants
  def archive
    Project.transaction do
      archive!
    end
    true
  end
  
  # Unarchives the project
  # All its ancestors must be active
  def unarchive
    return false if ancestors.detect {|a| !a.active?}
    update_attribute :status, STATUS_ACTIVE
  end
  
  # Returns an array of projects the project can be moved to
  # by the current user
  def allowed_parents
    return @allowed_parents if @allowed_parents
    @allowed_parents = Project.find(:all, :conditions => Project.allowed_to_condition(User.current, :add_subprojects))
    @allowed_parents = @allowed_parents - self_and_descendants
    if User.current.allowed_to?(:add_project, nil, :global => true)
      @allowed_parents << nil
    end
    unless parent.nil? || @allowed_parents.empty? || @allowed_parents.include?(parent)
      @allowed_parents << parent
    end
    @allowed_parents
  end
  
  # Sets the parent of the project with authorization check
  def set_allowed_parent!(p)
    unless p.nil? || p.is_a?(Project)
      if p.to_s.blank?
        p = nil
      else
        p = Project.find_by_id(p)
        return false unless p
      end
    end
    if p.nil?
      if !new_record? && allowed_parents.empty?
        return false
      end
    elsif !allowed_parents.include?(p)
      return false
    end
    set_parent!(p)
  end
  
  # Sets the parent of the project
  # Argument can be either a Project, a String, a Fixnum or nil
  # WARNING: This doesn't move the children for the project, if moving a project use: move_to_child_of
  def set_parent!(p)
    unless p.nil? || p.is_a?(Project)
      if p.to_s.blank?
        p = nil
      else
        p = Project.find_by_id(p)
        return false unless p
      end
    end
    if p == parent && !p.nil?
      # Nothing to do
      true
    elsif p.nil? || (p.active? && move_possible?(p))
      # Insert the project so that target's children or root projects stay alphabetically sorted
      sibs = (p.nil? ? self.class.roots : p.children)
      to_be_inserted_before = sibs.detect {|c| c.name.to_s.downcase > name.to_s.downcase }
      if to_be_inserted_before
        move_to_left_of(to_be_inserted_before)
      elsif p.nil?
        if sibs.empty?
          # move_to_root adds the project in first (ie. left) position
          move_to_root
        else
          move_to_right_of(sibs.last) unless self == sibs.last
        end
      else
        # move_to_child_of adds the project in last (ie.right) position
        move_to_child_of(p)
      end
      true
    else
      # Can not move to the given target
      false
    end
  end
  
  # Returns an array of the trackers used by the project and its active sub projects
  def rolled_up_trackers
    @rolled_up_trackers ||=
      Tracker.find(:all, :include => :projects,
                         :select => "DISTINCT #{Tracker.table_name}.*",
                         :conditions => ["#{Project.table_name}.lft >= ? AND #{Project.table_name}.rgt <= ? AND #{Project.table_name}.status = #{STATUS_ACTIVE}", lft, rgt],
                         :order => "#{Tracker.table_name}.position")
  end

  # Returns a hash of project users grouped by role
  def users_by_role
    all_members.find(:all, :include => [:user, :roles]).inject({}) do |h, m|
      m.roles.each do |r|
        h[r] ||= []
        h[r] << m.user
      end
      h
    end
  end

  # Returns a hash of active project users
  def active_members
    all_members.find(:all, :conditions => "roles.builtin = #{Role::BUILTIN_ACTIVE}",:include => [:user, :roles], :order => "firstname ASC")
  end

  # Returns a hash of project users with clearance
  def clearance_members
    all_members.find(:all, :conditions => "roles.builtin = #{Role::BUILTIN_CLEARANCE}",:include => [:user, :roles], :order => "firstname ASC")
  end

  # Returns a hash of contributers
  def contributor_list
    self.contributors
  end

  # Returns a hash of active project users grouped by role
  def member_list
    self.members
  end

  # Returns a hash of active project users grouped by role
  def core_member_list
    self.core_members
  end
  
  # Number of members who are active and have a binding vote
  def active_binding_members_count
    active_members = self.active_members.collect{|member| member.user_id}
    active_binding_members_count = (self.root.core_member_list.collect{|member| member.user_id} & active_members).length
    active_binding_members_count += (self.root.member_list.collect{|member| member.user_id} & active_members).length
  end

  def binding_members_count
    self.root.core_member_list.count + self.root.member_list.count  + self.root.member_list.count
  end
  
  # returns count of all users for this role and higher roles
  def role_and_above_count(position)
    all_members.count(:all, :conditions => "roles.position <= #{position}", :group => "user_id").length
  end
  
  
  # Retrieves a list of all active users for the past (x days) and refreshes their roles
  # Also refreshes members with clearance
  def refresh_active_members
    # return if self.root?
    return unless self.active?
    
    u = {}
    
    #Adding from activity stream
    self.activity_streams.recent.each do |as|
      u[as.actor_id] ||= as.actor_id
    end
    
    #Adding voters (do we really need this?)
    issues.each do |issue|
      next if (issue.updated_at.advance :days => Setting::DAYS_FOR_ACTIVE_MEMBERSHIP) > Time.now 
      issue.issue_votes.each do |iv|
        u[iv.user_id] ||= iv.user_id if (iv.updated_at.advance :days => Setting::DAYS_FOR_ACTIVE_MEMBERSHIP) > Time.now 
      end
    end
  
    u.delete nil
    u.delete User.sysadmin.id
    
    #removing active members that aren't in new list
    self.active_members.each do |m|
      if u[m.user_id].nil?
        new_m = Member.find(m.id)  #for some amazing reason, I have to reload the member to get all its roles! Otherwise, I only get the active roles
        a = new_m.role_ids
        a.delete Role.active.id 
        new_m.role_ids = a
      end
    end
    
    #adding active members that are in new list that aren't already active
    existing_active_members = self.active_members.collect(&:user_id)
    u.keys.each do |user_id|
      begin
        user = User.find(user_id)
        user.add_to_project(self, Role.active) unless existing_active_members.include? user_id 
      rescue #user not found (when deleting users)
      end
    end
    
    unless self.is_public?
      #giving clearance to all active members
      self.active_members.each do |m|
        User.find(m.user_id).add_to_project(self, Role.clearance)
      end
      
      #giving all root binding members clearance
      self.root.binding_members.each do |m|
        User.find(m.user_id).add_to_project(self, Role.clearance)
      end
    end
  end
  
  
  
  # Deletes all project's members
  def delete_all_members
    me, mr = Member.table_name, MemberRole.table_name
    connection.delete("DELETE FROM #{mr} WHERE #{mr}.member_id IN (SELECT #{me}.id FROM #{me} WHERE #{me}.project_id = #{id})")
    Member.delete_all(['project_id = ?', id])
  end
  
  # Users issues can be assigned to
  def assignable_users
    all_members.select {|m| m.roles.detect {|role| role.assignable?}}.collect {|m| m.user}.sort
  end
  
  # Returns the mail adresses of users that should be always notified on project events
  def recipients
    all_members.select {|m| m.mail_notification? || m.user.mail_notification?}.collect {|m| m.user.mail}
  end
  
  # Returns the users that should be notified on project events
  def notified_users
    all_members.select {|m| m.mail_notification? || m.user.mail_notification?}.collect {|m| m.user}
  end
  
  def project
    self
  end
  
  def <=>(project)
    name.downcase <=> project.name.downcase
  end
  
  def to_s
    name
  end
  
  def name_with_ancestors
    b = []

    ancestors = (project.root? ? [] : project.ancestors.visible)
    if ancestors.any?
      root = ancestors.shift
      b << root.name
      if ancestors.size > 2
        b << '...'
        ancestors = ancestors[-2, 2]
      end
      b += ancestors.collect {|p| p.name }
    end
    b << project.name
    b.join( ' » ')
  end
  
  # Returns a short description of the projects (first lines)
  def short_description(length = 255)
    description.gsub(/^(.{#{length}}[^\n\r]*).*$/m, '\1...').strip if description
  end
  
  # Return true if this project is allowed to do the specified action.
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allows_to?(action)
    if action.is_a? Hash
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end
  
  def module_enabled?(module_name)
    module_name = module_name.to_s
    enabled_modules.detect {|m| m.name == module_name}
  end
  
  def credits_enabled?
    !module_enabled?(:credits).nil?
  end
  
  def enabled_module_names=(module_names)
    if module_names && module_names.is_a?(Array)
      module_names = module_names.collect(&:to_s)
      # remove disabled modules
      enabled_modules.each {|mod| mod.destroy unless module_names.include?(mod.name)}
      # add new modules
      module_names.reject {|name| module_enabled?(name)}.each {|name| enabled_modules << EnabledModule.new(:name => name)}
    else
      enabled_modules.clear
    end
  end
  
  # Returns an auto-generated project identifier based on the last identifier used
  def self.next_identifier
    p = Project.find(:first, :order => 'created_at DESC')
    return 'A' if p.nil?
    
    next_id = p.identifier.to_s.succ
    
    while Project.exists?(:identifier => next_id)
      next_id = next_id.succ
    end
    
    next_id
    
  end

  # Copies and saves the Project instance based on the +project+.
  # Duplicates the source project's:
  # * Wiki
  # * Categories
  # * Issues
  # * Members
  # * Queries
  #
  # Accepts an +options+ argument to specify what to copy
  #
  # Examples:
  #   project.copy(1)                                    # => copies everything
  #   project.copy(1, :only => 'members')                # => copies members only
  #   project.copy(1, :only => ['members', 'versions'])  # => copies members and versions
  def copy(project, options={})
    project = project.is_a?(Project) ? project : Project.find(project)
    
    to_be_copied = %w(wiki issue_categories issues members queries boards)
    to_be_copied = to_be_copied & options[:only].to_a unless options[:only].nil?
    
    Project.transaction do
      if save
        reload
        to_be_copied.each do |name|
          send "copy_#{name}", project
        end
        save
      end
    end
  end

  
  # Copies +project+ and returns the new instance.  This will not save
  # the copy
  def self.copy_from(project)
    begin
      project = project.is_a?(Project) ? project : Project.find(project)
      if project
        # clear unique attributes
        attributes = project.attributes.dup.except('id', 'name', 'identifier', 'status', 'parent_id', 'lft', 'rgt')
        copy = Project.new(attributes)
        copy.enabled_modules = project.enabled_modules
        copy.trackers = project.trackers
        return copy
      else
        return nil
      end
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
  
  def team_points_for(user, options={})
    user.team_points_for(project)
  end
  
  #highest priority for open items in this project
  def highest_pri()
    self.issues.maximum(:pri, :conditions => {:status_id => IssueStatus.open.id }) || -9999
  end
  
  def before_validation_on_create
    self.enterprise_id = self.parent.enterprise_id unless self.parent.nil?
    self.identifier = Project.next_identifier
    self.invitation_token = Token.generate_token_value
    
    if self.credits_enabled?
      self.trackers = Tracker.all
    else
      self.trackers = Tracker.no_credits
    end
    return true
  end
    
  
  
  #Setup default forum for workstream
  def after_create
    logger.info { "entering after create" }
    #Send notification of request or invitation to recipient
     Board.create! :project_id => id,
                  :name => Setting.forum_name,                        
                  :description => Setting.forum_description + name              
                      
    self.refresh_activity_line
    self.save!
    return true
  end
  
  def set_owner
    logger.info { "parent id #{self.parent_id} and root #{self.root?} and root #{root?} and parent id #{parent_id} self #{self.inspect}" }
    
    if !self.root?
      self.update_attribute(:owner_id,self.root.owner_id) #unless self.owner_id == self.root.owner_id
      logger.info { "XXXXXXXXXXupdated attribute baby" }
    elsif owner_id.nil?
      self.owner_id = User.current.id if self.parent_id.nil?
      admins = self.administrators.sort {|x,y| x.created_at <=> y.created_at}
      if admins.length > 0
        self.owner_id = admins[0].user_id
        self.save
      else
        core = self.core_members.sort {|x,y| x.created_at <=> y.created_at}
        self.owner_id = core[0].user_id if core.length > 0
        self.save
      end
    end
    logger.info { "we didn't get the root. sorry." }
  end
  
  
  #Returns true if threshold of points that haven't been included in a retrospective have been created
  def ready_for_retro?
    return false if !credits_enabled?
    
    total_unretroed = Issue.sum(:points, 
                                :conditions => {
                                  :status_id => IssueStatus.accepted.id,
                                  :retro_id => Retro::NOT_STARTED_ID, 
                                  :project_id => id})
    return true if total_unretroed >= retro_credit_threshold
    
    #Getting most recent issue that's not part of retrospective
    first_issue = Issue.first(:conditions => {
                                :project_id => self.id, 
                                :status_id => IssueStatus.accepted, 
                                :retro_id => retro_credit_threshold}, 
                              :order => "updated_at asc")
    return false if first_issue == nil 
    return true if (first_issue.updated_at.advance :days => retro_credit_threshold) < Time.now
    
    return false
  end
  
  #Starts a new retrospective for this project
  def start_new_retro
    return false if !credits_enabled?
    
    from_date = issues.first(:conditions => {:retro_id => Retro::NOT_STARTED_ID}, :order => "updated_at ASC").updated_at
    total_points = issues.sum(:points, :conditions => {:retro_id => Retro::NOT_STARTED_ID})
    @retro = Retro.create :project_id => id, :status_id => Retro::STATUS_INPROGRESS,  :to_date => DateTime.now, :from_date => from_date, :total_points => total_points
    Issue.update_all("retro_id = #{@retro.id}" , "project_id = #{id} AND retro_id = #{Retro::NOT_STARTED_ID}")
    @retro.announce_start
  end
  
  #Starts a new retrospective if it's ready
  def start_retro_if_ready
    start_new_retro if ready_for_retro?
  end
  
  def refresh_activity_line
    date_array = Hash.new(0)
    for i in (1..Setting::ACTIVITY_LINE_LENGTH)
      date_array[(Date.today - i).to_s] = 0
    end
    
    #All issue votes
    iv_array = issue_votes.count(:group => 'DATE(issue_votes.created_at)', :conditions => "issue_votes.created_at > '#{(Date.today - Setting::ACTIVITY_LINE_LENGTH).to_s}'")
    my_line = date_array.merge iv_array

    #all issues
    iv_array = issues.count(:group => 'DATE(issues.updated_at)', :conditions => "issues.updated_at > '#{(Date.today - Setting::ACTIVITY_LINE_LENGTH).to_s}'")
    my_line + iv_array
    
    #all board messages
    iv_array = messages.count(:group => 'DATE(messages.updated_at)', :conditions => "messages.updated_at > '#{(Date.today - Setting::ACTIVITY_LINE_LENGTH).to_s}'")
    my_line + iv_array
    
    #all journals
    iv_array = issue_changes.count(:group => 'DATE(journals.updated_at)', :conditions => "journals.updated_at > '#{(Date.today - Setting::ACTIVITY_LINE_LENGTH).to_s}'")
    my_line + iv_array
    
    self.children.each do |sub_project| 
      my_line + sub_project.refresh_activity_line
    end
    
    self.activity_line = (my_line.sort.collect {|v| v[1]}).inspect.delete("[").delete("]")
    weight = 1
    activity_total = 0
    my_line.sort.each do |v|
      logger.info { "activity total #{activity_total} weight #{weight}  value #{v[1]}" }
      activity_total = activity_total +  (weight**1.7 * v[1])
      weight = weight + 1
    end
    self.activity_total = activity_total
    self.save
    my_line
  end
  
  def activity_line_max
    self.activity_line.split(',').max{|a,b| a.to_f <=> b.to_f}
  end
  
  def activity_line_show(length)
    activity_line.split(",").slice(self.activity_line.split(",").length - length,length).join(",")
  end
  
  def volunteer?
    return self.volunteer == true
  end
  
  def calculate_storage
    sum = 0
    documents.each do |d|
      sum += d.size
    end
    
    issues.each do |d|
      sum += d.size
    end
    
    self.storage = sum
    self.save
  end
  
  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
  end
  
  def refresh_issue_count
    self.issue_count = Issue.count(:conditions => {:project_id => self.id})
    self.save
  end
  
  private  
  # Copies wiki from +project+
  def copy_wiki(project)
    # Check that the source project has a wiki first
    unless project.wiki.nil?
      self.wiki ||= Wiki.new
      wiki.attributes = project.wiki.attributes.dup.except("id", "project_id")
      project.wiki.pages.each do |page|
        new_wiki_content = WikiContent.new(page.content.attributes.dup.except("id", "page_id", "updated_at"))
        new_wiki_page = WikiPage.new(page.attributes.dup.except("id", "wiki_id", "created_at", "parent_id"))
        new_wiki_page.content = new_wiki_content
        wiki.pages << new_wiki_page
      end
    end
  end

  
  # Copies issues from +project+
  def copy_issues(project)
    # Stores the source issue id as a key and the copied issues as the
    # value.  Used to map the two togeather for issue relations.
    issues_map = {}
    
    project.issues.each do |issue|
      new_issue = Issue.new
      new_issue.copy_from(issue)
      self.issues << new_issue
      issues_map[issue.id] = new_issue
    end

    # Relations after in case issues related each other
    project.issues.each do |issue|
      new_issue = issues_map[issue.id]
      
      # Relations
      issue.relations_from.each do |source_relation|
        new_issue_relation = IssueRelation.new
        new_issue_relation.attributes = source_relation.attributes.dup.except("id", "issue_from_id", "issue_to_id")
        new_issue_relation.issue_to = issues_map[source_relation.issue_to_id]
        if new_issue_relation.issue_to.nil? && Setting.cross_project_issue_relations?
          new_issue_relation.issue_to = source_relation.issue_to
        end
        new_issue.relations_from << new_issue_relation
      end
      
      issue.relations_to.each do |source_relation|
        new_issue_relation = IssueRelation.new
        new_issue_relation.attributes = source_relation.attributes.dup.except("id", "issue_from_id", "issue_to_id")
        new_issue_relation.issue_from = issues_map[source_relation.issue_from_id]
        if new_issue_relation.issue_from.nil? && Setting.cross_project_issue_relations?
          new_issue_relation.issue_from = source_relation.issue_from
        end
        new_issue.relations_to << new_issue_relation
      end
    end
  end

  # Copies members from +project+
  def copy_members(project)
    project.all_members.each do |member|
      new_member = Member.new
      new_member.attributes = member.attributes.dup.except("id", "project_id", "created_at")
      new_member.role_ids = member.role_ids.dup
      new_member.project = self
      self.all_members << new_member
    end
  end

  # Copies queries from +project+
  def copy_queries(project)
    project.queries.each do |query|
      new_query = Query.new
      new_query.attributes = query.attributes.dup.except("id", "project_id", "sort_criteria")
      new_query.sort_criteria = query.sort_criteria if query.sort_criteria
      new_query.project = self
      self.queries << new_query
    end
  end

  # Copies boards from +project+
  def copy_boards(project)
    project.boards.each do |board|
      new_board = Board.new
      new_board.attributes = board.attributes.dup.except("id", "project_id", "topics_count", "messages_count", "last_message_id")
      new_board.project = self
      self.boards << new_board
    end
  end
  
  def allowed_permissions
    @allowed_permissions ||= begin
      module_names = enabled_modules.collect {|m| m.name}
      Redmine::AccessControl.modules_permissions(module_names).collect {|p| p.name}
    end
  end
  
  # Archives subprojects recursively
  def archive!
    children.each do |subproject|
      subproject.send :archive!
    end
    update_attribute :status, STATUS_ARCHIVED
  end
end














# == Schema Information
#
# Table name: projects
#
#  id                   :integer         not null, primary key
#  name                 :string(30)      default(""), not null
#  description          :text
#  homepage             :string(255)     default("")
#  is_public            :boolean         default(TRUE), not null
#  parent_id            :integer
#  created_at           :datetime
#  updated_at           :datetime
#  identifier           :string(20)
#  status               :integer         default(1), not null
#  lft                  :integer
#  rgt                  :integer
#  enterprise_id        :integer
#  last_item_updated_on :datetime
#  dpp                  :float           default(100.0)
#  activity_line        :text            default("[]")
#  volunteer            :boolean         default(FALSE)
#  owner_id             :integer
#  storage              :float           default(0.0)
#  issue_count          :integer         default(0)
#

