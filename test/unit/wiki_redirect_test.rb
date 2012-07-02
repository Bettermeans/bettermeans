# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class WikiRedirectTest < ActiveSupport::TestCase
  fixtures :projects, :wikis

  def setup
    @wiki = Wiki.find(1)
    @original = WikiPage.create(:wiki => @wiki, :title => 'Original title')
  end

  def test_create_redirect
    @original.title = 'New title'
    assert @original.save
    @original.reload

    assert_equal 'New_title', @original.title
    assert @wiki.redirects.find_by_title('Original_title')
    assert @wiki.find_page('Original title')
  end

  def test_update_redirect
    # create a redirect that point to this page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.title = 'New title'
    @original.save
    # make sure the old page now points to the new page
    assert_equal 'New_title', @wiki.find_page('An old page').title
  end

  def test_reverse_rename
    # create a redirect that point to this page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.title = 'An old page'
    @original.save
    assert !@wiki.redirects.find_by_title_and_redirects_to('An_old_page', 'An_old_page')
    assert @wiki.redirects.find_by_title_and_redirects_to('Original_title', 'An_old_page')
  end

  def test_rename_to_already_redirected
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Other_page')

    @original.title = 'An old page'
    @original.save
    # this redirect have to be removed since 'An old page' page now exists
    assert !@wiki.redirects.find_by_title_and_redirects_to('An_old_page', 'Other_page')
  end

  def test_redirects_removed_when_deleting_page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.destroy
    assert !@wiki.redirects.find(:first)
  end
end


# == Schema Information
#
# Table name: wiki_redirects
#
#  id           :integer         not null, primary key
#  wiki_id      :integer         not null
#  title        :string(255)
#  redirects_to :string(255)
#  created_at   :datetime        not null
#

