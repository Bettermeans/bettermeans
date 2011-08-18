# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class WikiPageTest < ActiveSupport::TestCase
  fixtures :projects, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  def setup
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end
  
  def test_create
    page = WikiPage.new(:wiki => @wiki)
    assert !page.save
    assert_equal 1, page.errors.count
  
    page.title = "Page"
    assert page.save
    page.reload
    
    @wiki.reload
    assert @wiki.pages.include?(page)
  end
  
  def test_find_or_new_page
    page = @wiki.find_or_new_page("CookBook documentation")
    assert_kind_of WikiPage, page
    assert !page.new_record?
    
    page = @wiki.find_or_new_page("Non existing page")
    assert_kind_of WikiPage, page
    assert page.new_record?
  end
  
  def test_parent_title
    page = WikiPage.find_by_title('Another_page')
    assert_nil page.parent_title
    
    page = WikiPage.find_by_title('Page_with_an_inline_image')
    assert_equal 'CookBook documentation', page.parent_title
  end
  
  def test_assign_parent
    page = WikiPage.find_by_title('Another_page')
    page.parent_title = 'CookBook documentation'
    assert page.save
    page.reload
    assert_equal WikiPage.find_by_title('CookBook_documentation'), page.parent
  end
  
  def test_unassign_parent
    page = WikiPage.find_by_title('Page_with_an_inline_image')
    page.parent_title = ''
    assert page.save
    page.reload
    assert_nil page.parent
  end
  
  def test_parent_validation
    page = WikiPage.find_by_title('CookBook_documentation')
    
    # A page that doesn't exist
    page.parent_title = 'Unknown title'
    assert !page.save
    assert_equal I18n.translate('activerecord.errors.messages.invalid'), page.errors.on(:parent_title)
    # A child page
    page.parent_title = 'Page_with_an_inline_image'
    assert !page.save
    assert_equal I18n.translate('activerecord.errors.messages.circular_dependency'), page.errors.on(:parent_title)
    # The page itself
    page.parent_title = 'CookBook_documentation'
    assert !page.save
    assert_equal I18n.translate('activerecord.errors.messages.circular_dependency'), page.errors.on(:parent_title)

    page.parent_title = 'Another_page'
    assert page.save
  end
  
  def test_destroy
    page = WikiPage.find(1)
    page.destroy
    assert_nil WikiPage.find_by_id(1)
    # make sure that page content and its history are deleted
    assert WikiContent.find_all_by_page_id(1).empty?
    assert WikiContent.versioned_class.find_all_by_page_id(1).empty?
  end
  
  def test_destroy_should_not_nullify_children
    page = WikiPage.find(2)
    child_ids = page.child_ids
    assert child_ids.any?
    page.destroy
    assert_nil WikiPage.find_by_id(2)
    
    children = WikiPage.find_all_by_id(child_ids)
    assert_equal child_ids.size, children.size
    children.each do |child|
      assert_nil child.parent_id
    end
  end
end


# == Schema Information
#
# Table name: wiki_pages
#
#  id         :integer         not null, primary key
#  wiki_id    :integer         not null
#  title      :string(255)     not null
#  created_at :datetime        not null
#  protected  :boolean         default(FALSE), not null
#  parent_id  :integer
#

