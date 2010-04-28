# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class RetroRating < ActiveRecord::Base
  belongs_to :retro
  belongs_to :rater, :class_name => 'User', :foreign_key => 'rater_id'
  belongs_to :ratee, :class_name => 'User', :foreign_key => 'ratee_id'
end


# == Schema Information
#
# Table name: retro_ratings
#
#  id         :integer         not null, primary key
#  rater_id   :integer
#  ratee_id   :integer
#  score      :float
#  retro_id   :integer
#  created_on :datetime
#  updated_on :datetime
#  confidence :integer         default(100)
#

