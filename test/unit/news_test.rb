# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#

require File.dirname(__FILE__) + '/../test_helper'

class NewsTest < ActiveSupport::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :enabled_modules, :news

  def valid_news
    { :title => 'Test news', :description => 'Lorem ipsum etc', :author => User.find(:first) }
  end


  def setup
  end

  def test_create_should_send_email_notification
    ActionMailer::Base.deliveries.clear
    Setting.notified_events << 'news_added'
    news = Project.find(:first).news.new(valid_news)

    assert news.save
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_should_include_news_for_projects_with_news_enabled
    project = projects(:projects_001)
    assert project.enabled_modules.any?{ |em| em.name == 'news' }

    # News.latest should return news from projects_001
    assert News.latest.any? { |news| news.project == project }
  end

  def test_should_not_include_news_for_projects_with_news_disabled
    # The projects_002 (OnlineStore) doesn't have the news module enabled, use that project for this test
    project = projects(:projects_002)
    assert ! project.enabled_modules.any?{ |em| em.name == 'news' }

    # Add a piece of news to the project
    news = project.news.create(valid_news)

    # News.latest should not return that new piece of news
    assert News.latest.include?(news) == false
  end

  def test_should_only_include_news_from_projects_visibly_to_the_user
    # users_001 has no memberships so can only get news from public project
    assert News.latest(users(:users_001)).all? { |news| news.project.is_public? }
  end

  def test_should_limit_the_amount_of_returned_news
    # Make sure we have a bunch of news stories
    10.times { projects(:projects_001).news.create(valid_news) }
    assert_equal 2, News.latest(users(:users_002), 2).size
    assert_equal 6, News.latest(users(:users_002), 6).size
  end

  def test_should_return_5_news_stories_by_default
    # Make sure we have a bunch of news stories
    10.times { projects(:projects_001).news.create(valid_news) }
    assert_equal 5, News.latest(users(:users_004)).size
  end
end


# == Schema Information
#
# Table name: news
#
#  id             :integer         not null, primary key
#  project_id     :integer
#  title          :string(60)      default(""), not null
#  summary        :string(255)     default("")
#  description    :text
#  author_id      :integer         default(0), not null
#  created_at     :datetime
#  comments_count :integer         default(0), not null
#

