# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Workflow < ActiveRecord::Base
  belongs_to :role
  belongs_to :old_status, :class_name => 'IssueStatus', :foreign_key => 'old_status_id'
  belongs_to :new_status, :class_name => 'IssueStatus', :foreign_key => 'new_status_id'

  validates_presence_of :role, :old_status, :new_status
  
  # Returns workflow transitions count by tracker and role
  def self.count_by_tracker_and_role
    counts = connection.select_all("SELECT role_id, tracker_id, count(id) AS c FROM #{Workflow.table_name} GROUP BY role_id, tracker_id")
    roles = Role.find(:all, :order => 'builtin, position')
    trackers = Tracker.find(:all, :order => 'position')
    
    result = []
    trackers.each do |tracker|
      t = []
      roles.each do |role|
        row = counts.detect {|c| c['role_id'] == role.id.to_s && c['tracker_id'] == tracker.id.to_s}
        t << [role, (row.nil? ? 0 : row['c'].to_i)]
      end
      result << [tracker, t]
    end
    
    result
  end
end


# == Schema Information
#
# Table name: workflows
#
#  id            :integer         not null, primary key
#  tracker_id    :integer         default(0), not null
#  old_status_id :integer         default(0), not null
#  new_status_id :integer         default(0), not null
#  role_id       :integer         default(0), not null
#

