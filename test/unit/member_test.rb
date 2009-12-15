# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase
  fixtures :users, :projects, :roles, :members, :member_roles

  def setup
    @jsmith = Member.find(1)
  end
  
  def test_create
    member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
    assert member.save
    member.reload
    
    assert_equal 2, member.roles.size
    assert_equal Role.find(1), member.roles.sort.first
  end

  def test_update    
    assert_equal "eCookbook", @jsmith.project.name
    assert_equal "Manager", @jsmith.roles.first.name
    assert_equal "jsmith", @jsmith.user.login
    
    @jsmith.mail_notification = !@jsmith.mail_notification
    assert @jsmith.save
  end

  def test_update_roles
    assert_equal 1, @jsmith.roles.size
    @jsmith.role_ids = [1, 2]
    assert @jsmith.save
    assert_equal 2, @jsmith.reload.roles.size
  end
  
  def test_validate
    member = Member.new(:project_id => 1, :user_id => 2, :role_ids => [2])
    # same use can't have more than one membership for a project
    assert !member.save
    
    member = Member.new(:project_id => 1, :user_id => 2, :role_ids => [])
    # must have one role at least
    assert !member.save
  end
  
  def test_destroy
    assert_difference 'Member.count', -1 do
      assert_difference 'MemberRole.count', -1 do
        @jsmith.destroy
      end
    end
    
    assert_raise(ActiveRecord::RecordNotFound) { Member.find(@jsmith.id) }
  end
end


# == Schema Information
#
# Table name: members
#
#  id                :integer         not null, primary key
#  user_id           :integer         default(0), not null
#  project_id        :integer         default(0), not null
#  created_on        :datetime
#  mail_notification :boolean         default(FALSE), not null
#

