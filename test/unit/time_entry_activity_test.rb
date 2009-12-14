# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class TimeEntryActivityTest < ActiveSupport::TestCase
  fixtures :enumerations, :time_entries

  def test_should_be_an_enumeration
    assert TimeEntryActivity.ancestors.include?(Enumeration)
  end
  
  def test_objects_count
    assert_equal 3, TimeEntryActivity.find_by_name("Design").objects_count
    assert_equal 1, TimeEntryActivity.find_by_name("Development").objects_count
  end

  def test_option_name
    assert_equal :enumeration_activities, TimeEntryActivity.new.option_name
  end

  def test_create_with_custom_field
    field = TimeEntryActivityCustomField.find_by_name('Billable')
    e = TimeEntryActivity.new(:name => 'Custom Data')
    e.custom_field_values = {field.id => "1"}
    assert e.save

    e.reload
    assert_equal "1", e.custom_value_for(field).value
  end

  def test_create_without_required_custom_field_should_fail
    field = TimeEntryActivityCustomField.find_by_name('Billable')
    field.update_attribute(:is_required, true)

    e = TimeEntryActivity.new(:name => 'Custom Data')
    assert !e.save
    assert_equal I18n.translate('activerecord.errors.messages.invalid'), e.errors.on(:custom_values)
  end

  def test_create_with_required_custom_field_should_succeed
    field = TimeEntryActivityCustomField.find_by_name('Billable')
    field.update_attribute(:is_required, true)

    e = TimeEntryActivity.new(:name => 'Custom Data')
    e.custom_field_values = {field.id => "1"}
    assert e.save
  end

  def test_update_issue_with_required_custom_field_change
    field = TimeEntryActivityCustomField.find_by_name('Billable')
    field.update_attribute(:is_required, true)

    e = TimeEntryActivity.find(10)
    assert e.available_custom_fields.include?(field)
    # No change to custom field, record can be saved
    assert e.save
    # Blanking custom field, save should fail
    e.custom_field_values = {field.id => ""}
    assert !e.save
    assert e.errors.on(:custom_values)
    
    # Update custom field to valid value, save should succeed
    e.custom_field_values = {field.id => "0"}
    assert e.save
    e.reload
    assert_equal "0", e.custom_value_for(field).value
  end

end



# == Schema Information
#
# Table name: enumerations
#
#  id         :integer         not null, primary key
#  opt        :string(4)       default(""), not null
#  name       :string(30)      default(""), not null
#  position   :integer         default(1)
#  is_default :boolean         default(FALSE), not null
#  type       :string(255)
#  active     :boolean         default(TRUE), not null
#  project_id :integer
#  parent_id  :integer
#

