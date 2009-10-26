# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Watcher < ActiveRecord::Base
  belongs_to :watchable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [:watchable_type, :watchable_id]
  
  protected
  
  def validate
    errors.add :user_id, :invalid unless user.nil? || user.active?
  end
end
