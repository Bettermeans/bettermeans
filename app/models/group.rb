# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

class Group < Principal
  has_and_belongs_to_many :users, :after_add => :user_added,
                                  :after_remove => :user_removed
  
  acts_as_customizable
  
  validates_presence_of :lastname
  validates_uniqueness_of :lastname, :case_sensitive => false
  validates_length_of :lastname, :maximum => 30
    
  def to_s
    lastname.to_s
  end
  
  def user_added(user)
    members.each do |member|
      user_member = Member.find_by_project_id_and_user_id(member.project_id, user.id) || Member.new(:project_id => member.project_id, :user_id => user.id)
      member.member_roles.each do |member_role|
        user_member.member_roles << MemberRole.new(:role => member_role.role, :inherited_from => member_role.id)
      end
      user_member.save!
    end
  end
  
  def user_removed(user)
    members.each do |member|
      MemberRole.find(:all, :include => :member,
                            :conditions => ["#{Member.table_name}.user_id = ? AND #{MemberRole.table_name}.inherited_from IN (?)", user.id, member.member_role_ids]).each(&:destroy)
    end
  end
end
