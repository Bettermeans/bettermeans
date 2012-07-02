# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class AuthSource < ActiveRecord::Base
  has_many :users

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 60

  def authenticate(login, password)
  end

  def test_connection
  end

  def auth_method_name
    "Abstract"
  end

  # Try to authenticate a user not yet registered against available sources
  def self.authenticate(login, password)
    AuthSource.find(:all, :conditions => ["onthefly_register=?", true]).each do |source|
      begin
        logger.debug "Authenticating '#{login}' against '#{source.name}'" if logger && logger.debug?
        attrs = source.authenticate(login, password)
      rescue => e
        logger.error "Error during authentication: #{e.message}"
        attrs = nil
      end
      return attrs if attrs
    end
    return nil
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

