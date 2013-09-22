# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class AuthSource < ActiveRecord::Base
  has_many :users

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 60

  def authenticate(login, password) # spec_me cover_me heckle_me
  end

  def test_connection # spec_me cover_me heckle_me
  end

  def auth_method_name # spec_me cover_me heckle_me
    "Abstract"
  end

  # Try to authenticate a user not yet registered against available sources
  def self.authenticate(login, password) # spec_me cover_me heckle_me
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

