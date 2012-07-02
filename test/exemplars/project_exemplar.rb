class Project < ActiveRecord::Base
  generator_for :name, :method => :next_name
  generator_for :identifier, :method => :next_identifier_from_object_daddy
  generator_for :enabled_modules, :method => :all_modules
  generator_for :trackers, :method => :next_tracker

  def self.next_name
    @last_name ||= 'Project 0'
    @last_name.succ!
    @last_name
  end

  # Project#next_identifier is defined on Redmine
  def self.next_identifier_from_object_daddy
    @last_identifier ||= 'project0'
    @last_identifier.succ!
    @last_identifier
  end

  def self.all_modules
    returning [] do |modules|
      Redmine::AccessControl.available_project_modules.each do |name|
        modules << EnabledModule.new(:name => name.to_s)
      end
    end
  end

  def self.next_tracker
    [Tracker.generate!]
  end
end














# == Schema Information
#
# Table name: projects
#
#  id                   :integer         not null, primary key
#  name                 :string(30)      default(""), not null
#  description          :text
#  homepage             :string(255)     default("")
#  is_public            :boolean         default(TRUE), not null
#  parent_id            :integer
#  created_at           :datetime
#  updated_at           :datetime
#  identifier           :string(20)
#  status               :integer         default(1), not null
#  lft                  :integer
#  rgt                  :integer
#  enterprise_id        :integer
#  last_item_updated_on :datetime
#  dpp                  :float           default(100.0)
#  activity_line        :text            default("[]")
#  volunteer            :boolean         default(FALSE)
#  owner_id             :integer
#  storage              :float           default(0.0)
#  issue_count          :integer         default(0)
#

