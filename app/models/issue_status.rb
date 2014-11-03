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

  def self.ids_for(name) # spec_me cover_me heckle_me
    case name
    when 'new'
      [newstatus.id]
    when 'open'
      [open.id]
    when 'inprogress'
      [inprogress.id]
    when 'done'
      [done.id]
    when 'canceled'
      [canceled.id]
    end
  end

  # Returns the default status for new issues
  def self.default # spec_me cover_me heckle_me
    find(:first, :conditions =>["is_default=?", true])
  end

  def self.assigned # cover_me heckle_me
    @@assigned_status ||= find(:first, :conditions => ['name = ?', 'Committed'])
  end

  def self.done # cover_me heckle_me
    @@done_status ||= find(:first, :conditions => ['name = ?', 'Done'])
  end

  def self.inprogress # cover_me heckle_me
    @@inprogress_status ||= find(:first, :conditions =>['name = ?', 'Committed'])
  end

  def self.newstatus # cover_me heckle_me
    @@newstatus_status ||= find(:first, :conditions =>['name = ?', 'New'])
  end

  def self.open_id # spec_me cover_me heckle_me
    open.id if open
  end

  def self.open # cover_me heckle_me
    @@open_status ||= find(:first, :conditions =>['name = ?', 'Open'])
  end

  def self.canceled # cover_me heckle_me
    @@canceled_status ||= find(:first, :conditions =>['name = ?', 'Canceled'])
  end

  def self.estimate # cover_me heckle_me
    @@estimate_status ||= find(:first, :conditions =>['name = ?', 'Estimate'])
  end

  def self.accepted # cover_me heckle_me
    find(:first, :conditions =>['name = ?', 'Accepted'])
  end

  def self.rejected # cover_me heckle_me
    find(:first, :conditions =>['name = ?', 'Rejected'])
  end

  def self.archived # cover_me heckle_me
    @@archived_status ||= find(:first, :conditions =>['name = ?', 'Archived'])
  end

  def rejected?
    name == 'Rejected'
  end

  def accepted?
    name == 'Accepted'
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


