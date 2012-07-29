# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class RetroRating < ActiveRecord::Base

  TEAM_AVERAGE = -1 #retro ratings with a rater id of -1 represent the team average for the ratee
  FINAL_AVERAGE = -2 #final distribution for the ratee
  SELF_BIAS = -3 #difference between self assesment and final average as a percentage of final
  SCALE_BIAS = -4 #sum of differences in percentage points between user's assessment of self and others, and final average


  belongs_to :retro
  belongs_to :rater, :class_name => 'User', :foreign_key => 'rater_id'
  belongs_to :ratee, :class_name => 'User', :foreign_key => 'ratee_id'

  named_scope :for_project, lambda { |project_id|
    {
      :joins      => "JOIN retros ON retro_id = retros.id",
      :conditions => "retros.project_id = #{project_id}"
    }
  }

end

