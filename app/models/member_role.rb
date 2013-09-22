# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

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


  def project # spec_me cover_me heckle_me
    member.respond_to?(:project) ? member.project : nil
  end

  #used for activity stream
  def name # spec_me cover_me heckle_me
    role.name
  end

  def project_id # spec_me cover_me heckle_me
    project.id
  end

  def user_id # spec_me cover_me heckle_me
    member.user.id
  end

  def user # spec_me cover_me heckle_me
    member.user
  end

  def long_description # spec_me cover_me heckle_me
    "#{user.name} is now: #{role.name}"
  end

  def event_title # spec_me cover_me heckle_me
    "Team change"
  end

  private

  def remove_member_if_empty # cover_me heckle_me
    return unless member
    if member.roles.empty?
      member.destroy
    end# unless role_id == Role::BUILTIN_CORE_MEMBER #We don't destory the member if the role being removed is the core_member role since we're going to add a contributor role
  end

  def send_notification # cover_me heckle_me
    Notification.create :recipient_id => self.member.user_id,
                              :variation => 'new_role',
                              :params => {:role_name => self.role.name, :project_name => self.member.project.root.name, :enterprise_id => self.member.project.root.id},
                              :sender_id => User.sysadmin.id,
                              :source_type => "MemberRole",
                              :source_id => self.id if self.role.level == Role::LEVEL_ENTERPRISE
  end

  def log_activity # cover_me heckle_me
    return if role.active? || role.clearance? #don't log active memberships
    LogActivityStreams.write_single_activity_stream(User.sysadmin,:name,self,:name,:created,:memberships, 0, self.member.user,{:indirect_object_phrase => self.member.user.name})
  end

  #refreshes memberships for all private workstreams
  def refresh_memberships # cover_me heckle_me
    return unless member
    return unless role.level == Role::LEVEL_ENTERPRISE
    MemberRole.send_later(:refresh_memberships_delayed,self)
  end

  #refreshes memberships for all private workstreams
  def self.refresh_memberships_delayed(member_role) # cover_me heckle_me
    return unless member_role.member
    return unless member_role.role.level == Role::LEVEL_ENTERPRISE
    member_role.member.project.root.descendants.each(&:refresh_active_members) if member_role.member.project
  end

end

