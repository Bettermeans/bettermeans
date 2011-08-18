# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

class Member < ActiveRecord::Base
  
  belongs_to :user
  has_many :member_roles, :dependent => :destroy
  has_many :roles, :through => :member_roles
  belongs_to :project

  validates_presence_of :user, :project
  validates_uniqueness_of :user_id, :scope => :project_id

  after_destroy :unwatch_from_permission_change
  
  def name
    self.user.name if self.user
  end

  def name_and_id
    "#{self.user.id.to_s}:#{self.user.name}"
  end
  
  alias :base_role_ids= :role_ids=
  def role_ids=(arg)
    arg = [arg] unless arg.respond_to? :collect
    ids = (arg || []).collect(&:to_i) - [0]
    # Keep inherited roles
    ids += member_roles.select {|mr| !mr.inherited_from.nil?}.collect(&:role_id)
    new_role_ids = ids - role_ids
    # Add new roles
    new_role_ids.each {|id| member_roles << MemberRole.new(:role_id => id) }
    # Remove roles (Rails' #role_ids= will not trigger MemberRole#on_destroy)
    member_roles_to_destroy = member_roles.select {|mr| !ids.include?(mr.role_id)}
    if member_roles_to_destroy.any?
      member_roles_to_destroy.each(&:destroy)
      unwatch_from_permission_change
    end
  end
  
  def <=>(member)
    a, b = roles.sort.first, member.roles.sort.first
    a == b ? (user <=> member.user) : (a <=> b)
  end
  
  def deletable?
    member_roles.detect {|mr| mr.inherited_from}.nil?
  end  
  
  protected
  
  def validate
    errors.add_to_base "Role can't be blank" if member_roles.empty? && roles.empty?
  end
  
  private
  
  # Unwatch things that the user is no longer allowed to view inside project
  def unwatch_from_permission_change
    if user
      Watcher.prune(:user => user, :project => project)
    end
  end
end


# == Schema Information
#
# Table name: members
#
#  id                :integer         not null, primary key
#  user_id           :integer         default(0), not null
#  project_id        :integer         default(0), not null
#  created_at        :datetime
#  mail_notification :boolean         default(FALSE), not null
#

