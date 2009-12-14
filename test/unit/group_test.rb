# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :all

  def test_create
    g = Group.new(:lastname => 'New group')
    assert g.save
  end
  
  def test_roles_given_to_new_user
    group = Group.find(11)
    user = User.find(9)
    project = Project.first
    
    Member.create!(:principal => group, :project => project, :role_ids => [1, 2])
    group.users << user
    assert user.member_of?(project)
  end
  
  def test_roles_given_to_existing_user
    group = Group.find(11)
    user = User.find(9)
    project = Project.first
    
    group.users << user
    m = Member.create!(:principal => group, :project => project, :role_ids => [1, 2])
    assert user.member_of?(project)
  end
  
  def test_roles_updated
    group = Group.find(11)
    user = User.find(9)
    project = Project.first
    group.users << user
    m = Member.create!(:principal => group, :project => project, :role_ids => [1])
    assert_equal [1], user.reload.roles_for_project(project).collect(&:id).sort
    
    m.role_ids = [1, 2]
    assert_equal [1, 2], user.reload.roles_for_project(project).collect(&:id).sort
    
    m.role_ids = [2]
    assert_equal [2], user.reload.roles_for_project(project).collect(&:id).sort
    
    m.role_ids = [1]
    assert_equal [1], user.reload.roles_for_project(project).collect(&:id).sort
  end

  def test_roles_removed_when_removing_group_membership
    assert User.find(8).member_of?(Project.find(5))
    Member.find_by_project_id_and_user_id(5, 10).destroy
    assert !User.find(8).member_of?(Project.find(5))
  end

  def test_roles_removed_when_removing_user_from_group
    assert User.find(8).member_of?(Project.find(5))
    User.find(8).groups.clear
    assert !User.find(8).member_of?(Project.find(5))
  end
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

