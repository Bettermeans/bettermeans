# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class IssueStatus < ActiveRecord::Base
  before_destroy :check_integrity
  has_many :workflows, :foreign_key => "old_status_id", :dependent => :delete_all
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i

  def after_save # spec_me cover_me heckle_me
    IssueStatus.update_all("is_default=#{connection.quoted_false}", ['id <> ?', id]) if self.is_default?
  end

  # Returns the default status for new issues
  def self.default # spec_me cover_me heckle_me
    find(:first, :conditions =>["is_default=?", true])
  end

  def self.assigned # spec_me cover_me heckle_me
    @@assigned_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_assigned)])
  end

  def self.done # spec_me cover_me heckle_me
    @@done_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_done)])
  end

  def self.inprogress # spec_me cover_me heckle_me
    @@inprogress_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_inprogress)])
  end

  def self.newstatus # spec_me cover_me heckle_me
    @@newstatus_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_new)])
  end

  def self.open # spec_me cover_me heckle_me
    @@open_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_open)])
  end

  def self.canceled # spec_me cover_me heckle_me
    @@canceled_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_canceled)])
  end

  def self.estimate # spec_me cover_me heckle_me
    @@estimate_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_estimate)])
  end

  def self.accepted # spec_me cover_me heckle_me
    find(:first, :conditions =>["name=?", l(:default_issue_status_accepted)])
  end

  def self.rejected # spec_me cover_me heckle_me
    find(:first, :conditions =>["name=?", l(:default_issue_status_rejected)])
  end

  def self.archived # spec_me cover_me heckle_me
    @@archived_status ||= find(:first, :conditions =>["name=?", l(:default_issue_status_archived)])
  end



  # Returns an array of all statuses the given role can switch to
  # Uses association cache when called more than one time
  def new_statuses_allowed_to(roles, tracker) # spec_me cover_me heckle_me
    if roles && tracker
      role_ids = roles.collect(&:id)
      new_statuses = workflows.select {|w| role_ids.include?(w.role_id) && w.tracker_id == tracker.id}.collect{|w| w.new_status}.compact.sort
    else
      []
    end
  end

  # Same thing as above but uses a database query
  # More efficient than the previous method if called just once
  def find_new_statuses_allowed_to(roles, tracker) # spec_me cover_me heckle_me
    if roles && tracker
      workflows.find(:all,
                     :include => :new_status,
                     :conditions => { :role_id => roles.collect(&:id),
                                      :tracker_id => tracker.id}).collect{ |w| w.new_status }.compact.sort
    else
      []
    end
  end

  def new_status_allowed_to?(status, roles, tracker) # spec_me cover_me heckle_me
    if status && roles && tracker
      !workflows.find(:first, :conditions => {:new_status_id => status.id, :role_id => roles.collect(&:id), :tracker_id => tracker.id}).nil?
    else
      false
    end
  end

  def <=>(status) # spec_me cover_me heckle_me
    position <=> status.position
  end

  def to_s; name end # spec_me cover_me heckle_me


  private

  def check_integrity # cover_me heckle_me
    raise "Can't delete status" if Issue.find(:first, :conditions => ["status_id=?", self.id])
  end

end


