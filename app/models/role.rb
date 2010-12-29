# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Role < ActiveRecord::Base
  # fields do
  #   name :string, :limit => 30, :null => false, :default => ""
  #   position :integer, :default => 1
  #   assignable :boolean, :default => true
  #   builtin :integer, :default => 0, :null => false
  #   permissions :text
  #   level :integer, :default => 3
  # end
  
  # Scopes
  LEVEL_PLATFORM = 0
  LEVEL_ENTERPRISE = 1
  LEVEL_PROJECT = 2
  
  # Built-in roles
  BUILTIN_NON_MEMBER = 1 #scope platform
  BUILTIN_ANONYMOUS  = 2 #scope platform
  BUILTIN_ADMINISTRATOR = 3 #scope enterprise
  BUILTIN_CORE_MEMBER = 4 #scope enterprise
  BUILTIN_CONTRIBUTOR = 5 #scope enterprise
  BUILTIN_ACTIVE = 7 #scope project
  BUILTIN_MEMBER = 8 #scope enterprise
  BUILTIN_BOARD = 9 #scope enterprise
  BUILTIN_CLEARANCE = 10 #scope project

  named_scope :givable, { :conditions => "builtin = 0", :order => 'position' }
  named_scope :builtin, lambda { |*args|
    compare = 'not' if args.first == true
    { :conditions => "#{compare} builtin = 0" }
  }
  
  before_destroy :check_deletable
  has_many :workflows, :dependent => :delete_all do
    def copy(source_role)
      Workflow.copy(nil, source_role, nil, proxy_owner)
    end
  end
  
  has_many :member_roles, :dependent => :destroy
  has_many :members, :through => :member_roles
  acts_as_list
  
  serialize :permissions, Array
  # attr_protected :builtin #TODO: should we uncomment this again?

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i

  def permissions
    read_attribute(:permissions) || []
  end
  
  def permissions=(perms)
    perms = perms.collect {|p| p.to_sym unless p.blank? }.compact.uniq if perms
    write_attribute(:permissions, perms)
  end

  def add_permission!(*perms)
    self.permissions = [] unless permissions.is_a?(Array)

    permissions_will_change!
    perms.each do |p|
      p = p.to_sym
      permissions << p unless permissions.include?(p)
    end
    save!
  end

  def remove_permission!(*perms)
    return unless permissions.is_a?(Array)
    permissions_will_change!
    perms.each { |p| permissions.delete(p.to_sym) }
    save!
  end
  
  # Returns true if the role has the given permission
  def has_permission?(perm)
    !permissions.nil? && permissions.include?(perm.to_sym)
  end
  
  def <=>(role)
    role ? position <=> role.position : -1
  end
  
  def to_s
    name
  end
  
  # Return true if the role is a builtin role
  def builtin?
    self.builtin != 0
  end
  
  # Return true if the role belongs to the community in any way
  def community_member?
    builtin == BUILTIN_CONTRIBUTOR || builtin == BUILTIN_CORE_MEMBER || builtin == BUILTIN_MEMBER || builtin == BUILTIN_ADMINISTRATOR || builtin == BUILTIN_ACTIVE  || builtin == BUILTIN_BOARD || builtin == BUILTIN_CLEARANCE
  end

  # Return true if the role belongs to the enterprise (i.e. contributor, member, coreateam, admin, or board)
  def enterprise_member?
    level == LEVEL_ENTERPRISE
    # builtin == BUILTIN_CONTRIBUTOR || builtin == BUILTIN_CORE_MEMBER || builtin == BUILTIN_MEMBER || builtin == BUILTIN_ADMINISTRATOR || builtin == BUILTIN_BOARD
  end

  # Return true if the role is a binding member role
  def binding_member?
    builtin == BUILTIN_CORE_MEMBER || builtin == BUILTIN_MEMBER || builtin == BUILTIN_ADMINISTRATOR
  end
  
  # Return true if the role is a project core team member
  def core_member?
    builtin == BUILTIN_CORE_MEMBER
  end
  
  # Return true if the role is a project contributor
  def contributor?
    builtin == BUILTIN_CONTRIBUTOR
  end

  # Return true if the role is a project contributor
  def member?
    builtin == BUILTIN_MEMBER
  end  

  # Return true if the role is active
  def active?
    builtin == BUILTIN_ACTIVE
  end  
  
  # Return true if the role is a clearance
  def clearance?
    builtin == BUILTIN_CLEARANCE
  end  
  
  
  # Return true if role is allowed to do the specified action
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action)
    if action.is_a? Hash
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end
  
  # Return all the permissions that can be given to the role
  def setable_permissions
    setable_permissions = Redmine::AccessControl.permissions - Redmine::AccessControl.public_permissions
    setable_permissions -= Redmine::AccessControl.members_only_permissions if self.builtin == BUILTIN_NON_MEMBER
    setable_permissions -= Redmine::AccessControl.loggedin_only_permissions if self.builtin == BUILTIN_ANONYMOUS
    setable_permissions
  end

  # Find all the roles that can be given to a project member
  def self.find_all_givable(level)
    find(:all, :conditions => {:level => level}, :order => 'position') 
  end

  # Return the builtin 'non member' role
  def self.non_member
    find(:first, :conditions => {:builtin => BUILTIN_NON_MEMBER}) || raise('Missing non-member builtin role.')
  end

  # Return the builtin 'anonymous' role 
  def self.anonymous
    find(:first, :conditions => {:builtin => BUILTIN_ANONYMOUS}) || raise('Missing anonymous builtin role.')
  end
  

  # Return the builtin 'administrator' role 
  def self.administrator
    find(:first, :conditions => {:builtin => BUILTIN_ADMINISTRATOR}) || raise('Missing Administrator builtin role.')
  end

  # Return the builtin 'board' role 
  def self.board
    find(:first, :conditions => {:builtin => BUILTIN_BOARD}) || raise('Missing Board builtin role.')
  end


  # Return the builtin 'contributor' role 
  def self.contributor
    find(:first, :conditions => {:builtin => BUILTIN_CONTRIBUTOR}) || raise('Missing contributor builtin role.')
  end


  # Return the builtin 'core member' role 
  def self.core_member
    find(:first, :conditions => {:builtin => BUILTIN_CORE_MEMBER}) || raise('Missing core member builtin role.')
  end

  # Return the builtin 'member' role 
  def self.member
    find(:first, :conditions => {:builtin => BUILTIN_MEMBER}) || raise('Missing member builtin role.')
  end

  # Return the builtin 'founder' role 
  def self.founder
    find(:first, :conditions => {:builtin => BUILTIN_FOUNDER}) || raise('Missing founder builtin role.')
  end

  # Return the builtin 'clearance' role 
  def self.clearance
    find(:first, :conditions => {:builtin => BUILTIN_CLEARANCE}) || raise('Missing clearance builtin role.')
  end

  # Return the builtin 'active' role 
  def self.active
    find(:first, :conditions => {:builtin => BUILTIN_ACTIVE}) || raise('Missing active builtin role.')
  end

  
private
  def allowed_permissions
    @allowed_permissions ||= permissions + Redmine::AccessControl.public_permissions.collect {|p| p.name}
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
  end
    
  def check_deletable
    raise "Can't delete role" if members.any?
    raise "Can't delete builtin role" if builtin?
  end
end


# == Schema Information
#
# Table name: roles
#
#  id          :integer         not null, primary key
#  name        :string(30)      default(""), not null
#  position    :integer         default(1)
#  assignable  :boolean         default(TRUE)
#  builtin     :integer         default(0), not null
#  permissions :text
#  level       :integer         default(3)
#

