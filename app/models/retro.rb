# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Retro < ActiveRecord::Base
    
  #Constants
  STATUS_INPROGRESS = 1
  STATUS_COMPLETE = 2
  STATUS_INDISPUTE = 3
  NOT_STARTED_ID = -1 #fake is for issues that haven't been started yet
  
  belongs_to :project
  has_many :issues
  has_many :journals, :through => :issues
  has_many :issue_votes, :through => :issues
  has_many :retro_ratings
  
  #Sets the from_date according to earliest updated issue in retrospective
  def set_from_date
    from_date = issues.first(:order => "updated_on ASC").updated_on
    save! #BUGBUG: doesn't work
  end
end



# == Schema Information
#
# Table name: retros
#
#  id         :integer         not null, primary key
#  status_id  :integer
#  project_id :integer
#  from_date  :datetime
#  to_date    :datetime
#  created_on :datetime
#  updated_on :datetime
#

