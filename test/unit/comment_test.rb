# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :users, :news, :comments

  def setup
    @jsmith = User.find(2)
    @news = News.find(1)
  end

  def test_create
    comment = Comment.new(:commented => @news, :author => @jsmith, :comments => "my comment")
    assert comment.save
    @news.reload
    assert_equal 2, @news.comments_count
  end

  def test_validate
    comment = Comment.new(:commented => @news)
    assert !comment.save
    assert_equal 2, comment.errors.length
  end

  def test_destroy
    comment = Comment.find(1)
    assert comment.destroy
    @news.reload
    assert_equal 0, @news.comments_count
  end
end


# == Schema Information
#
# Table name: comments
#
#  id             :integer         not null, primary key
#  commented_type :string(30)      default(""), not null
#  commented_id   :integer         default(0), not null
#  author_id      :integer         default(0), not null
#  comments       :text
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

