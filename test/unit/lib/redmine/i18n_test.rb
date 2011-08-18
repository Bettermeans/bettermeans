# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../../../test_helper'

class Redmine::I18nTest < ActiveSupport::TestCase
  include Redmine::I18n
  include ActionView::Helpers::NumberHelper
  
  def setup
    @hook_module = Redmine::Hook
  end
  
  def test_date_format_default
    set_language_if_valid 'en'
    today = Date.today
    Setting.date_format = ''    
    assert_equal I18n.l(today), format_date(today)
  end
  
  def test_date_format
    set_language_if_valid 'en'
    today = Date.today
    Setting.date_format = '%d %m %Y'
    assert_equal today.strftime('%d %m %Y'), format_date(today)
  end
  
  def test_date_and_time_for_each_language
    Setting.date_format = ''
    valid_languages.each do |lang|
      set_language_if_valid lang
      assert_nothing_raised "#{lang} failure" do
        format_date(Date.today)
        format_time(Time.now)
        format_time(Time.now, false)
        assert_not_equal 'default', ::I18n.l(Date.today, :format => :default), "date.formats.default missing in #{lang}"
        assert_not_equal 'time',    ::I18n.l(Time.now, :format => :time),      "time.formats.time missing in #{lang}"
      end
      assert l('date.day_names').is_a?(Array)
      assert_equal 7, l('date.day_names').size
      
      assert l('date.month_names').is_a?(Array)
      assert_equal 13, l('date.month_names').size
    end
  end
  
  def test_time_format_default
    set_language_if_valid 'en'
    now = Time.now
    Setting.date_format = ''
    Setting.time_format = ''    
    assert_equal I18n.l(now), format_time(now)
    assert_equal I18n.l(now, :format => :time), format_time(now, false)
  end
  
  def test_time_format
    set_language_if_valid 'en'
    now = Time.now
    Setting.date_format = '%d %m %Y'
    Setting.time_format = '%H %M'
    assert_equal now.strftime('%d %m %Y %H %M'), format_time(now)
    assert_equal now.strftime('%H %M'), format_time(now, false)
  end
  
  def test_utc_time_format
    set_language_if_valid 'en'
    now = Time.now.utc
    Setting.date_format = '%d %m %Y'
    Setting.time_format = '%H %M'
    assert_equal Time.now.strftime('%d %m %Y %H %M'), format_time(now)
    assert_equal Time.now.strftime('%H %M'), format_time(now, false)
  end
  
  def test_number_to_human_size_for_each_language
    valid_languages.each do |lang|
      set_language_if_valid lang
      assert_nothing_raised "#{lang} failure" do
        number_to_human_size(1024*1024*4)
      end
    end
  end
  
  def test_valid_languages
    assert valid_languages.is_a?(Array)
    assert valid_languages.first.is_a?(Symbol)
  end
  
  def test_valid_language
    to_test = {'fr' => :fr,
               'Fr' => :fr,
               'zh' => :zh,
               'zh-tw' => :"zh-TW",
               'zh-TW' => :"zh-TW",
               'zh-ZZ' => nil }
    
    to_test.each {|lang, expected| assert_equal expected, find_language(lang)}
  end
end
