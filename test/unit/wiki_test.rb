# encoding: utf-8
#
# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions
  
  def test_create
    wiki = Wiki.new(:project => Project.find(2))
    assert !wiki.save
    assert_equal 1, wiki.errors.count
  
    wiki.start_page = "Start page"
    assert wiki.save
  end

  def test_update
    @wiki = Wiki.find(1)
    @wiki.start_page = "Another start page"
    assert @wiki.save
    @wiki.reload
    assert_equal "Another start page", @wiki.start_page
  end
  
  def test_titleize
    assert_equal 'Page_title_with_CAPITALES', Wiki.titleize('page title with CAPITALES')
    assert_equal 'テスト', Wiki.titleize('テスト')
  end
end


# == Schema Information
#
# Table name: wikis
#
#  id         :integer         not null, primary key
#  project_id :integer         not null
#  start_page :string(255)     not null
#  status     :integer         default(1), not null
#

