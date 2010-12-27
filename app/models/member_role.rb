# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class MemberRole < ActiveRecord::Base
  
  belongs_to :member
  belongs_to :role
  
  after_create :send_notification, :log_activity , :refresh_memberships

  after_destroy :remove_member_if_empty, :refresh_memberships
  
  validates_presence_of :role
  
  acts_as_event :title => :event_title,
                :description => :long_description,
                :author =>  :user,
                :type => 'member-role',
                :url => Proc.new {|o| {:controller => 'projects', :action => 'team', :id => o.member.project_id}}
    
  
  # def validate
    # errors.add :role_id, :invalid if role && !role.community_member?
  # end
  
  def project
    member.respond_to?(:project) ? member.project : nil
  end
  
  #used for activity stream
  def name
    role.name
  end
  
  def project_id
    project.id
  end
  
  def user_id
    member.user.id
  end
  
  def user
    member.user
  end
  
  def long_description
    "#{user.name} is now: #{role.name}"
  end
  
  def event_title
    "Team change"
  end
  
  private
  
  def remove_member_if_empty
    return unless member
    if member.roles.empty?
      member.destroy
    end# unless role_id == Role::BUILTIN_CORE_MEMBER #We don't destory the member if the role being removed is the core_member role since we're going to add a contributor role    
  end
  
  
  def send_notification
    Notification.create :recipient_id => self.member.user_id,
                              :variation => 'new_role',
                              :params => {:role_name => self.role.name, :project_name => self.member.project.root.name, :enterprise_id => self.member.project.root.id}, 
                              :sender_id => User.sysadmin.id,
                              :source_id => self.id if self.role.level == Role::LEVEL_ENTERPRISE    
  end
  
  def log_activity
    # def self.write_single_activity_stream(actor,actor_name,object,object_name,verb,activity, status, indirect_object, options)
    return if role.active? || role.clearance? #don't log active memberships
    # LogActivityStreams.write_single_activity_stream(User.sysadmin,:name,self,:name,:created,:memberships, 0, nil,{})
  end
  
  #refreshes memberships for all private workstreams
  def refresh_memberships
    return unless member
    return unless role.level == Role::LEVEL_ENTERPRISE
    member.project.root.descendants.each(&:refresh_active_members) if member.project
  end
  
  # #Removes all contributor roles for this member if the current role being added is core
  # def remove_contributor_role_if_core
  #   MemberRole.find(:all, :conditions => {:member_id => member_id, :role_id => Role::BUILTIN_CONTRIBUTOR}).each(&:destroy) if role_id == Role::BUILTIN_CORE_MEMBER
  # end
  # 
  # #Adds contributor roles for this member if the current role being destroyed is core
  # def add_contributor_role_if_core
  #   if role_id == Role::BUILTIN_CORE_MEMBER
  #     m = MemberRole.new :member_id => member_id, :role_id => Role::BUILTIN_CONTRIBUTOR 
  #     m.save
  #   end
  # end
  
  
end


# == Schema Information
#
# Table name: member_roles
#
#  id             :integer         not null, primary key
#  member_id      :integer
#  role_id        :integer
#  inherited_from :integer
#  created_at     :datetime
#  updated_at     :datetime
#

