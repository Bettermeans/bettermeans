# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

class Token < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :value

  before_create :delete_previous_tokens

  @@validity_time = 30.day

  def before_create
    self.value = Token.generate_token_value
  end

  # Return true if token has expired
  def expired?
    return Time.now > self.created_at + @@validity_time
  end

  # Delete all expired tokens
  def self.destroy_expired
    Token.delete_all ["action <> 'feeds' AND created_at < ?", Time.now - @@validity_time]
  end

private
  def self.generate_token_value
    ActiveSupport::SecureRandom.hex(20)
  end

  # Removes obsolete tokens (same user and action)
  def delete_previous_tokens
    if user
      Token.delete_all(['user_id = ? AND action = ?', user.id, action])
    end
  end
end


# == Schema Information
#
# Table name: tokens
#
#  id         :integer         not null, primary key
#  user_id    :integer         default(0), not null
#  action     :string(30)      default(""), not null
#  value      :string(40)      default(""), not null
#  created_at :datetime        not null
#

