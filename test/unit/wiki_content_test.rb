# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class WikiContentTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions, :users

  def setup
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end

  def test_create
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "Content text", :author => User.find(1), :comments => "My comment")
    assert page.save
    page.reload

    content = page.content
    assert_kind_of WikiContent, content
    assert_equal 1, content.version
    assert_equal 1, content.versions.length
    assert_equal "Content text", content.text
    assert_equal "My comment", content.comments
    assert_equal User.find(1), content.author
    assert_equal content.text, content.versions.last.text
  end

  def test_create_should_send_email_notification
    Setting.notified_events = ['wiki_content_added']
    ActionMailer::Base.deliveries.clear
    page = WikiPage.new(:wiki => @wiki, :title => "A new page")
    page.content = WikiContent.new(:text => "Content text", :author => User.find(1), :comments => "My comment")
    assert page.save

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_update
    content = @page.content
    version_count = content.version
    content.text = "My new content"
    assert content.save
    content.reload
    assert_equal version_count+1, content.version
    assert_equal version_count+1, content.versions.length
  end

  def test_update_should_send_email_notification
    Setting.notified_events = ['wiki_content_updated']
    ActionMailer::Base.deliveries.clear
    content = @page.content
    content.text = "My new content"
    assert content.save

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_fetch_history
    assert !@page.content.versions.empty?
    @page.content.versions.each do |version|
      assert_kind_of String, version.text
    end
  end
end



# == Schema Information
#
# Table name: wiki_contents
#
#  id         :integer         not null, primary key
#  page_id    :integer         not null
#  author_id  :integer
#  text       :text
#  comments   :string(255)     default("")
#  updated_on :datetime        not null
#  version    :integer         not null
#

