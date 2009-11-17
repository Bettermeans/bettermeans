# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Board < ActiveRecord::Base
  belongs_to :project
  has_many :topics, :class_name => 'Message', :conditions => "#{Message.table_name}.parent_id IS NULL", :order => "#{Message.table_name}.created_on DESC"
  has_many :messages, :dependent => :delete_all, :order => "#{Message.table_name}.created_on DESC"
  belongs_to :last_message, :class_name => 'Message', :foreign_key => :last_message_id
  acts_as_list :scope => :project_id
  acts_as_watchable

  
  validates_presence_of :name, :description
  validates_length_of :name, :maximum => 30
  validates_length_of :description, :maximum => 255
  
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
