# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../../test_helper'

class CustomFieldsHelperTest < HelperTestCase
  include CustomFieldsHelper
  include Redmine::I18n
  
  def test_format_boolean_value
    I18n.locale = 'en'
    assert_equal 'Yes', format_value('1', 'bool')
    assert_equal 'No', format_value('0', 'bool')
  end
end
