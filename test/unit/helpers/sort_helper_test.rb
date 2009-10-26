# Redmine - project management software
# Copyright (C) 2006-2009  Shereef Bishay
#

require File.dirname(__FILE__) + '/../../test_helper'

class SortHelperTest < HelperTestCase
  include SortHelper
  
  def setup
    @session = nil
    @sort_param = nil
  end
  
  def test_default_sort_clause_with_array
    sort_init 'attr1', 'desc'
    sort_update(['attr1', 'attr2'])

    assert_equal 'attr1 DESC', sort_clause
  end
  
  def test_default_sort_clause_with_hash
    sort_init 'attr1', 'desc'
    sort_update({'attr1' => 'table1.attr1', 'attr2' => 'table2.attr2'})

    assert_equal 'table1.attr1 DESC', sort_clause
  end
  
  def test_default_sort_clause_with_multiple_columns
    sort_init 'attr1', 'desc'
    sort_update({'attr1' => ['table1.attr1', 'table1.attr2'], 'attr2' => 'table2.attr2'})

    assert_equal 'table1.attr1 DESC, table1.attr2 DESC', sort_clause
  end
  
  def test_params_sort
    @sort_param = 'attr1,attr2:desc'
    
    sort_init 'attr1', 'desc'
    sort_update({'attr1' => 'table1.attr1', 'attr2' => 'table2.attr2'})

    assert_equal 'table1.attr1, table2.attr2 DESC', sort_clause
    assert_equal 'attr1,attr2:desc', @session['foo_bar_sort']
  end
  
  def test_invalid_params_sort
    @sort_param = 'invalid_key'
    
    sort_init 'attr1', 'desc'
    sort_update({'attr1' => 'table1.attr1', 'attr2' => 'table2.attr2'})

    assert_equal 'table1.attr1 DESC', sort_clause
    assert_equal 'attr1:desc', @session['foo_bar_sort']
  end
  
  def test_invalid_order_params_sort
    @sort_param = 'attr1:foo:bar,attr2'
    
    sort_init 'attr1', 'desc'
    sort_update({'attr1' => 'table1.attr1', 'attr2' => 'table2.attr2'})

    assert_equal 'table1.attr1, table2.attr2', sort_clause
    assert_equal 'attr1,attr2', @session['foo_bar_sort']
  end
  
  private
  
  def controller_name; 'foo'; end
  def action_name; 'bar'; end
  def params; {:sort => @sort_param}; end
  def session; @session ||= {}; end
end
