# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class IssueStatus < ActiveRecord::Base
  before_destroy :check_integrity  
  has_many :workflows, :foreign_key => "old_status_id", :dependent => :delete_all
  acts_as_list

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i

  def after_save
    IssueStatus.update_all("is_default=#{connection.quoted_false}", ['id <> ?', id]) if self.is_default?
  end  
  
  # Returns the default status for new issues
  def self.default
    find(:first, :conditions =>["is_default=?", true])
  end

  # Returns an array of all statuses the given role can switch to
  # Uses association cache when called more than one time
  def new_statuses_allowed_to(roles, tracker)
    if roles && tracker
      role_ids = roles.collect(&:id)
      new_statuses = workflows.select {|w| role_ids.include?(w.role_id) && w.tracker_id == tracker.id}.collect{|w| w.new_status}.compact.sort
    else
      []
    end
  end
  
  # Same thing as above but uses a database query
  # More efficient than the previous method if called just once
  def find_new_statuses_allowed_to(roles, tracker)
    if roles && tracker
      workflows.find(:all,
                     :include => :new_status,
                     :conditions => { :role_id => roles.collect(&:id), 
                                      :tracker_id => tracker.id}).collect{ |w| w.new_status }.compact.sort
    else
      []
    end
  end
  
  def new_status_allowed_to?(status, roles, tracker)
    if status && roles && tracker
      !workflows.find(:first, :conditions => {:new_status_id => status.id, :role_id => roles.collect(&:id), :tracker_id => tracker.id}).nil?
    else
      false
    end
  end

  def <=>(status)
    position <=> status.position
  end
  
  def to_s; name end

private
  def check_integrity
    raise "Can't delete status" if Issue.find(:first, :conditions => ["status_id=?", self.id])
  end
end
