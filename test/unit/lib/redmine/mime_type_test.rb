# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../../../test_helper'

class Redmine::MimeTypeTest < ActiveSupport::TestCase

  def test_of
    to_test = {'test.unk' => nil,
               'test.txt' => 'text/plain',
               'test.c' => 'text/x-c',
               }
    to_test.each do |name, expected|
      assert_equal expected, Redmine::MimeType.of(name)
    end
  end

  def test_css_class_of
    to_test = {'test.unk' => nil,
               'test.txt' => 'text-plain',
               'test.c' => 'text-x-c',
               }
    to_test.each do |name, expected|
      assert_equal expected, Redmine::MimeType.css_class_of(name)
    end
  end

  def test_main_mimetype_of
    to_test = {'test.unk' => nil,
               'test.txt' => 'text',
               'test.c' => 'text',
               }
    to_test.each do |name, expected|
      assert_equal expected, Redmine::MimeType.main_mimetype_of(name)
    end
  end

  def test_is_type
    to_test = {['text', 'test.unk'] => false,
               ['text', 'test.txt'] => true,
               ['text', 'test.c'] => true,
               }
    to_test.each do |args, expected|
      assert_equal expected, Redmine::MimeType.is_type?(*args)
    end
  end
end
