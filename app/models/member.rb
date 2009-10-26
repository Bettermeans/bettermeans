# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :principal, :foreign_key => 'user_id'
  has_many :member_roles, :dependent => :destroy
  has_many :roles, :through => :member_roles
  belongs_to :project

  validates_presence_of :principal, :project
  validates_uniqueness_of :user_id, :scope => :project_id
  
  def name
    self.user.name
  end
  
  alias :base_role_ids= :role_ids=
  def role_ids=(arg)
    ids = (arg || []).collect(&:to_i) - [0]
    # Keep inherited roles
    ids += member_roles.select {|mr| !mr.inherited_from.nil?}.collect(&:role_id)
    
    new_role_ids = ids - role_ids
    # Add new roles
    new_role_ids.each {|id| member_roles << MemberRole.new(:role_id => id) }
    # Remove roles (Rails' #role_ids= will not trigger MemberRole#on_destroy)
    member_roles.select {|mr| !ids.include?(mr.role_id)}.each(&:destroy)
  end
  
  def <=>(member)
    a, b = roles.sort.first, member.roles.sort.first
    a == b ? (principal <=> member.principal) : (a <=> b)
  end
  
  def deletable?
    member_roles.detect {|mr| mr.inherited_from}.nil?
  end
  
  def before_destroy
    if user
      # remove category based auto assignments for this member
      IssueCategory.update_all "assigned_to_id = NULL", ["project_id = ? AND assigned_to_id = ?", project.id, user.id]
    end
  end
  
  protected
  
  def validate
    errors.add_to_base "Role can't be blank" if member_roles.empty? && roles.empty?
  end
end
