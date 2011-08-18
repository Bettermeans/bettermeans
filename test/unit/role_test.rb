# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles, :workflows

  def test_copy_workflows
    source = Role.find(1)
    assert_equal 90, source.workflows.size
    
    target = Role.new(:name => 'Target')
    assert target.save
    target.workflows.copy(source)
    target.reload
    assert_equal 90, target.workflows.size
  end

  def test_add_permission
    role = Role.find(1)
    size = role.permissions.size
    role.add_permission!("apermission", "anotherpermission")
    role.reload
    assert role.permissions.include?(:anotherpermission)
    assert_equal size + 2, role.permissions.size
  end

  def test_remove_permission
    role = Role.find(1)
    size = role.permissions.size
    perm = role.permissions[0..1]
    role.remove_permission!(*perm)
    role.reload
    assert ! role.permissions.include?(perm[0])
    assert_equal size - 2, role.permissions.size
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

