# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Board < ActiveRecord::Base
  belongs_to :project
  has_many :topics, :class_name => 'Message', :conditions => "#{Message.table_name}.parent_id IS NULL", :order => "#{Message.table_name}.created_at DESC"
  has_many :messages, :dependent => :delete_all, :order => "#{Message.table_name}.created_at DESC"
  belongs_to :last_message, :class_name => 'Message', :foreign_key => :last_message_id
  acts_as_list :scope => :project_id
  acts_as_watchable


  validates_presence_of :name, :description
  validates_length_of :name, :maximum => 30
  validates_length_of :description, :maximum => 255

  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_messages, project)
  end

  def to_s
    name
  end

  def reset_counters!
    self.class.reset_counters!(id)
  end

  # Updates topics_count, messages_count and last_message_id attributes for +board_id+
  def self.reset_counters!(board_id)
    board_id = board_id.to_i
    update_all("topics_count = (SELECT COUNT(*) FROM #{Message.table_name} WHERE board_id=#{board_id} AND parent_id IS NULL)," +
               " messages_count = (SELECT COUNT(*) FROM #{Message.table_name} WHERE board_id=#{board_id})," +
               " last_message_id = (SELECT MAX(id) FROM #{Message.table_name} WHERE board_id=#{board_id})",
               ["id = ?", board_id])
  end
end


# == Schema Information
#
# Table name: boards
#
#  id              :integer         not null, primary key
#  project_id      :integer         not null
#  name            :string(255)     default(""), not null
#  description     :string(255)
#  position        :integer         default(1)
#  topics_count    :integer         default(0), not null
#  messages_count  :integer         default(0), not null
#  last_message_id :integer
#

