# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Comment < ActiveRecord::Base
  belongs_to :commented, :polymorphic => true, :counter_cache => true
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :commented, :author, :comments
end
