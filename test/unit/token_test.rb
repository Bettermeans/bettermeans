# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class TokenTest < ActiveSupport::TestCase
  fixtures :tokens

  def test_create
    token = Token.new
    token.save
    assert_equal 40, token.value.length
    assert !token.expired?
  end
  
  def test_create_should_remove_existing_tokens
    user = User.find(1)
    t1 = Token.create(:user => user, :action => 'autologin')
    t2 = Token.create(:user => user, :action => 'autologin')
    assert_not_equal t1.value, t2.value
    assert !Token.exists?(t1.id)
    assert  Token.exists?(t2.id)
  end
end
