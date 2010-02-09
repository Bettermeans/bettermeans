# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Retro < ActiveRecord::Base
  
  include ActionController::UrlWriter
  include ActionView::Helpers
  
  #Constants
  STATUS_INPROGRESS = 1
  STATUS_COMPLETE = 2
  STATUS_INDISPUTE = 3
  NOT_STARTED_ID = -1 #is for issues that haven't been started yet
  NOT_NEEDED_ID = -1 #is for issues that don't need a retrospective b/c only one person worked on them
  
  DEFAULT_RETROSPECTIVE_LENGTH = 3 #Length in days for which a retrospective is open
  
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
  
  def close
    @H = Hash.new
    
    retro_ratings.group_by{|retro_rating| retro_rating.rater_id}.keys.each do |user_id|
      next if user_id = -1;
      @H[user_id] = []
    end
    
    retro_ratings.each do |rr|
      next if rr.rater_id = -1;
      @H[rr.ratee_id].push rr.score unless rr.ratee_id == rr.rater_id
    end
    
    RetroRating.delete_all :rater_id => -1, :retro_id => self.id
    @H.keys.each do |user_id|
      RetroRating.create :rater_id => -1, :ratee_id => user_id, :score => @H[user_id].sum.to_f / @H[user_id].length, :retro_id => self.id
    end
    
    self.status_id = STATUS_COMPLETE
    self.save
  end
  
  #Sends notification to everyone in the retrospective that it's starting
  def announce
    @users = Hash.new
    issue_votes.each do |issue_vote|
      @users[issue_vote.user_id] = 1 if issue_vote.vote_type == IssueVote::JOIN_VOTE_TYPE
    end
    
    admin = User.find(:first,:conditions => {:login => "admin"})
    
    @users.keys.each do |user_id|
      Notification.create :recipient_id => user_id,
                          :variation => 'retro_started',
                          :params => {}, 
                          :sender_id => admin.id,
                          :source_id => self.id    
    end
  end
  
  #True when all team members in a retrospective have participated
  def all_in?
    retro_group = retro_ratings.group_by {|retro_rating| retro_rating.rater_id}
    team_group = issue_votes.select{|issue_vote| issue_vote.vote_type == IssueVote::JOIN_VOTE_TYPE}
    return team_group.length <= retro_group.length
  end
end




# == Schema Information
#
# Table name: retros
#
#  id           :integer         not null, primary key
#  status_id    :integer
#  project_id   :integer
#  from_date    :datetime
#  to_date      :datetime
#  created_on   :datetime
#  updated_on   :datetime
#  total_points :integer
#

