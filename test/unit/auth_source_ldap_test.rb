# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class AuthSourceLdapTest < ActiveSupport::TestCase

  def setup
  end

  def test_create
    a = AuthSourceLdap.new(:name => 'My LDAP', :host => 'ldap.example.net', :port => 389, :base_dn => 'dc=example,dc=net', :attr_login => 'sAMAccountName')
    assert a.save
  end

  def test_should_strip_ldap_attributes
    a = AuthSourceLdap.new(:name => 'My LDAP', :host => 'ldap.example.net', :port => 389, :base_dn => 'dc=example,dc=net', :attr_login => 'sAMAccountName',
                           :attr_firstname => 'givenName ')
    assert a.save
    assert_equal 'givenName', a.reload.attr_firstname
  end
end


# == Schema Information
#
# Table name: auth_sources
#
#  id                :integer         not null, primary key
#  type              :string(30)      default(""), not null
#  name              :string(60)      default(""), not null
#  host              :string(60)
#  port              :integer
#  account           :string(255)
#  account_password  :string(60)
#  base_dn           :string(255)
#  attr_login        :string(30)
#  attr_firstname    :string(30)
#  attr_lastname     :string(30)
#  attr_mail         :string(30)
#  onthefly_register :boolean         default(FALSE), not null
#  tls               :boolean         default(FALSE), not null
#

