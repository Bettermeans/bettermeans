# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class CustomValueTest < ActiveSupport::TestCase
  fixtures :custom_fields, :custom_values, :users

  def test_string_field_validation_with_blank_value
    f = CustomField.new(:field_format => 'string')
    v = CustomValue.new(:custom_field => f)
    
    v.value = nil
    assert v.valid?
    v.value = ''
    assert v.valid?

    f.is_required = true
    v.value = nil
    assert !v.valid?
    v.value = ''
    assert !v.valid?
  end
  
  def test_string_field_validation_with_min_and_max_lengths
    f = CustomField.new(:field_format => 'string', :min_length => 2, :max_length => 5)
    v = CustomValue.new(:custom_field => f, :value => '')
    assert v.valid?
    v.value = 'a'
    assert !v.valid?
    v.value = 'a' * 2
    assert v.valid?
    v.value = 'a' * 6
    assert !v.valid?
  end
  
  def test_string_field_validation_with_regexp
    f = CustomField.new(:field_format => 'string', :regexp => '^[A-Z0-9]*$')
    v = CustomValue.new(:custom_field => f, :value => '')
    assert v.valid?
    v.value = 'abc'
    assert !v.valid?
    v.value = 'ABC'
    assert v.valid?
  end

  def test_date_field_validation
    f = CustomField.new(:field_format => 'date')
    v = CustomValue.new(:custom_field => f, :value => '')
    assert v.valid?
    v.value = 'abc'
    assert !v.valid?
    v.value = '1975-07-14'
    assert v.valid?
  end

  def test_list_field_validation
    f = CustomField.new(:field_format => 'list', :possible_values => ['value1', 'value2'])
    v = CustomValue.new(:custom_field => f, :value => '')
    assert v.valid?
    v.value = 'abc'
    assert !v.valid?
    v.value = 'value2'
    assert v.valid?
  end

  def test_int_field_validation
    f = CustomField.new(:field_format => 'int')
    v = CustomValue.new(:custom_field => f, :value => '')
    assert v.valid?
    v.value = 'abc'
    assert !v.valid?
    v.value = '123'
    assert v.valid?
    v.value = '+123'
    assert v.valid?
    v.value = '-123'
    assert v.valid?
  end
  
  def test_float_field_validation
    v = CustomValue.new(:customized => User.find(:first), :custom_field => UserCustomField.find_by_name('Money'))
    v.value = '11.2'
    assert v.save
    v.value = ''
    assert v.save
    v.value = '-6.250'
    assert v.save
    v.value = '6a'
    assert !v.save
  end
  
  def test_default_value
    field = CustomField.find_by_default_value('Default string')
    assert_not_nil field
    
    v = CustomValue.new(:custom_field => field)
    assert_equal 'Default string', v.value

    v = CustomValue.new(:custom_field => field, :value => 'Not empty')
    assert_equal 'Not empty', v.value
  end
  
  def test_sti_polymorphic_association
    # Rails uses top level sti class for polymorphic association. See #3978.
    assert !User.find(4).custom_values.empty?
    assert !CustomValue.find(2).customized.nil?
  end
end


# == Schema Information
#
# Table name: custom_values
#
#  id              :integer         not null, primary key
#  customized_type :string(30)      default(""), not null
#  customized_id   :integer         default(0), not null
#  custom_field_id :integer         default(0), not null
#  value           :text
#

