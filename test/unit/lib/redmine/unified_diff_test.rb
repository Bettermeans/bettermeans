# Redmine - project management software
# Copyright (C) 2006-2008  Shereef Bishay
#

require File.dirname(__FILE__) + '/../../../test_helper'

class Redmine::UnifiedDiffTest < ActiveSupport::TestCase
  
  def setup
  end

  def test_subversion_diff
    diff = Redmine::UnifiedDiff.new(read_diff_fixture('subversion.diff'))
    # number of files
    assert_equal 4, diff.size
    assert diff.detect {|file| file.file_name =~ %r{^config/settings.yml}}
  end
  
  def test_truncate_diff
    diff = Redmine::UnifiedDiff.new(read_diff_fixture('subversion.diff'), :max_lines => 20)
    assert_equal 2, diff.size
  end

  private
  
  def read_diff_fixture(filename)
    File.new(File.join(File.dirname(__FILE__), '/../../../fixtures/diffs', filename)).read
  end
end
