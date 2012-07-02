# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'

class ChangesetTest < ActiveSupport::TestCase
  fixtures :projects, :repositories, :issues, :issue_statuses, :changesets, :changes, :issue_categories, :enumerations, :custom_fields, :custom_values, :users, :members, :member_roles, :trackers

  def setup
  end

  def test_ref_keywords_any
    ActionMailer::Base.deliveries.clear
    Setting.commit_fix_status_id = IssueStatus.find(:first, :conditions => ["is_closed = ?", true]).id
    Setting.commit_fix_done_ratio = '90'
    Setting.commit_ref_keywords = '*'
    Setting.commit_fix_keywords = 'fixes , closes'

    c = Changeset.new(:repository => Project.find(1).repository,
                      :committed_on => Time.now,
                      :comments => 'New commit (#2). Fixes #1')
    c.scan_comment_for_issue_ids

    assert_equal [1, 2], c.issue_ids.sort
    fixed = Issue.find(1)
    assert fixed.closed?
    assert_equal 90, fixed.done_ratio
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_ref_keywords_any_line_start
    Setting.commit_ref_keywords = '*'

    c = Changeset.new(:repository => Project.find(1).repository,
                      :committed_on => Time.now,
                      :comments => '#1 is the reason of this commit')
    c.scan_comment_for_issue_ids

    assert_equal [1], c.issue_ids.sort
  end

  def test_ref_keywords_allow_brackets_around_a_issue_number
    Setting.commit_ref_keywords = '*'

    c = Changeset.new(:repository => Project.find(1).repository,
                      :committed_on => Time.now,
                      :comments => '[#1] Worked on this issue')
    c.scan_comment_for_issue_ids

    assert_equal [1], c.issue_ids.sort
  end

  def test_ref_keywords_allow_brackets_around_multiple_issue_numbers
    Setting.commit_ref_keywords = '*'

    c = Changeset.new(:repository => Project.find(1).repository,
                      :committed_on => Time.now,
                      :comments => '[#1 #2, #3] Worked on these')
    c.scan_comment_for_issue_ids

    assert_equal [1,2,3], c.issue_ids.sort
  end

  def test_previous
    changeset = Changeset.find_by_revision('3')
    assert_equal Changeset.find_by_revision('2'), changeset.previous
  end

  def test_previous_nil
    changeset = Changeset.find_by_revision('1')
    assert_nil changeset.previous
  end

  def test_next
    changeset = Changeset.find_by_revision('2')
    assert_equal Changeset.find_by_revision('3'), changeset.next
  end

  def test_next_nil
    changeset = Changeset.find_by_revision('10')
    assert_nil changeset.next
  end
end


# == Schema Information
#
# Table name: changesets
#
#  id            :integer         not null, primary key
#  repository_id :integer         not null
#  revision      :string(255)     not null
#  committer     :string(255)
#  committed_on  :datetime        not null
#  comments      :text
#  commit_date   :date
#  scmid         :string(255)
#  user_id       :integer
#

