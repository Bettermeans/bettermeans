# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

class Comment < ActiveRecord::Base
  belongs_to :commented, :polymorphic => true, :counter_cache => true
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :commented, :author, :comments  
end


# == Schema Information
#
# Table name: comments
#
#  id             :integer         not null, primary key
#  commented_type :string(30)      default(""), not null
#  commented_id   :integer         default(0), not null
#  author_id      :integer         default(0), not null
#  comments       :text
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

