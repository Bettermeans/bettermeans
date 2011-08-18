# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class UserPreferenceTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences

  def test_create
    user = User.new(:firstname => "new", :lastname => "user", :mail => "newuser@somenet.foo")
    user.login = "newuser"
    user.password, user.password_confirmation = "password", "password"
    assert user.save
    
    assert_kind_of UserPreference, user.pref
    assert_kind_of Hash, user.pref.others
    assert user.pref.save
  end
  
  def test_update
    user = User.find(1)
    assert_equal true, user.pref.hide_mail
    user.pref['preftest'] = 'value'
    assert user.pref.save
    
    user.reload
    assert_equal 'value', user.pref['preftest']
  end
end



# == Schema Information
#
# Table name: user_preferences
#
#  id        :integer         not null, primary key
#  user_id   :integer         default(0), not null
#  others    :text
#  hide_mail :boolean         default(TRUE)
#  time_zone :string(255)
#

