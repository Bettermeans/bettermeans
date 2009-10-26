# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../test_helper'

class DocumentCategoryTest < ActiveSupport::TestCase
  fixtures :enumerations, :documents

  def test_should_be_an_enumeration
    assert DocumentCategory.ancestors.include?(Enumeration)
  end
  
  def test_objects_count
    assert_equal 1, DocumentCategory.find_by_name("Uncategorized").objects_count
    assert_equal 0, DocumentCategory.find_by_name("User documentation").objects_count
  end

  def test_option_name
    assert_equal :enumeration_doc_categories, DocumentCategory.new.option_name
  end
end

