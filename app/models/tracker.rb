# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Tracker < ActiveRecord::Base
  before_destroy :check_integrity
  has_many :issues
  has_many :workflows, :dependent => :delete_all do
    def copy(source_tracker)
      Workflow.copy(source_tracker, nil, proxy_owner, nil)
    end
  end

  has_and_belongs_to_many :projects
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i

  def to_s; name end

  def <=>(tracker)
    name <=> tracker.name
  end

  def self.all
    find(:all, :order => 'position')
  end

  #All trackers except the ones that apply to the credits module
  def self.no_credits
    find(:all, :conditions => {:for_credits_module => false}, :order => 'position')
  end


  def gift?
    name == l(:default_issue_tracker_gift)
  end

  def expense?
    name == l(:default_issue_tracker_expense)
  end

  def recurring?
    name == l(:default_issue_tracker_recurring)
  end

  def hourly?
    name == l(:default_issue_tracker_hourly)
  end

  def feature?
    name == l(:default_issue_tracker_feature)
  end

  def bug?
    name == l(:default_issue_tracker_bug)
  end

  def chore?
    name == l(:default_issue_tracker_chore)
  end


  # Returns an array of IssueStatus that are used
  # in the tracker's workflows
  def issue_statuses
    if @issue_statuses
      return @issue_statuses
    elsif new_record?
      return []
    end

    ids = Workflow.
            connection.select_rows("SELECT DISTINCT old_status_id, new_status_id FROM #{Workflow.table_name} WHERE tracker_id = #{id}").
            flatten.
            uniq

    @issue_statuses = IssueStatus.find_all_by_id(ids).sort
  end

  private

  def check_integrity
    raise "Can't delete tracker" if Issue.find(:first, :conditions => ["tracker_id=?", self.id])
  end

end



# == Schema Information
#
# Table name: trackers
#
#  id                 :integer         not null, primary key
#  name               :string(30)      default(""), not null
#  is_in_chlog        :boolean         default(FALSE), not null
#  position           :integer         default(1)
#  is_in_roadmap      :boolean         default(TRUE), not null
#  for_credits_module :boolean         default(FALSE)
#

