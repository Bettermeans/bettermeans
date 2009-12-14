# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class CustomFieldTest < ActiveSupport::TestCase
  fixtures :custom_fields
  
  def test_create
    field = UserCustomField.new(:name => 'Money money money', :field_format => 'float')
    assert field.save
  end
  
  def test_possible_values_should_accept_an_array
    field = CustomField.new
    field.possible_values = ["One value", ""]
    assert_equal ["One value"], field.possible_values
  end
  
  def test_possible_values_should_accept_a_string
    field = CustomField.new
    field.possible_values = "One value"
    assert_equal ["One value"], field.possible_values
  end
  
  def test_possible_values_should_accept_a_multiline_string
    field = CustomField.new
    field.possible_values = "One value\nAnd another one  \r\n \n"
    assert_equal ["One value", "And another one"], field.possible_values
  end
  
  def test_destroy
    field = CustomField.find(1)
    assert field.destroy
  end
end


# == Schema Information
#
# Table name: custom_fields
#
#  id              :integer         not null, primary key
#  type            :string(30)      default(""), not null
#  name            :string(30)      default(""), not null
#  field_format    :string(30)      default(""), not null
#  possible_values :text
#  regexp          :string(255)     default("")
#  min_length      :integer         default(0), not null
#  max_length      :integer         default(0), not null
#  is_required     :boolean         default(FALSE), not null
#  is_for_all      :boolean         default(FALSE), not null
#  is_filter       :boolean         default(FALSE), not null
#  position        :integer         default(1)
#  searchable      :boolean         default(FALSE)
#  default_value   :text
#  editable        :boolean         default(TRUE)
#

