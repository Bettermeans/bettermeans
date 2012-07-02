# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
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

  def test_line_starting_with_dashes
    diff = Redmine::UnifiedDiff.new(<<-DIFF
--- old.txt Wed Nov 11 14:24:58 2009
+++ new.txt Wed Nov 11 14:25:02 2009
@@ -1,8 +1,4 @@
-Lines that starts with dashes:
-
-------------------------
--- file.c
-------------------------
+A line that starts with dashes:

 and removed.

@@ -23,4 +19,4 @@



-Another chunk of change
+Another chunk of changes

DIFF
    )
    assert_equal 1, diff.size
  end

  private

  def read_diff_fixture(filename)
    File.new(File.join(File.dirname(__FILE__), '/../../../fixtures/diffs', filename)).read
  end
end
