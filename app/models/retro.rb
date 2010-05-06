# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class Retro < ActiveRecord::Base
  
  include ActionController::UrlWriter
  include ActionView::Helpers
  
  #Constants
  STATUS_INPROGRESS = 1
  STATUS_COMPLETE = 2 #is closed, but credits haven't been distributed yet
  STATUS_DISTRIBUTED = 3 #credits have been distributed
  STATUS_DISPUTED = 9
  NOT_STARTED_ID = -1 #is for issues that haven't been started yet
  NOT_NEEDED_ID = -2 #is for issues that don't need a retrospective b/c only one person worked on them
  
  
  belongs_to :project
  has_many :issues
  has_many :journals, :through => :issues
  has_many :issue_votes, :through => :issues
  has_many :retro_ratings
  has_many :credit_disributions
  

  
  #Sets the from_date according to earliest updated issue in retrospective
  def set_from_date
    from_date = issues.first(:order => "updated_on ASC").updated_on
    self.save
  end
  
  def ended?
    return status_id == STATUS_COMPLETE || status_id == STATUS_DISTRIBUTED
  end
  
  #For closed retrospectives
  def distribute_credits
    return unless status_id == STATUS_COMPLETE
    return if retro_ratings.length == 0
    total_dollars = 0 #Total dollar amount for retrospsective
    issues.each do |issue|
      total_dollars+= issue.dollar_amount
    end

    retro_ratings.find_all{|retro_rating| retro_rating.rater_id == -2}.each do |rr|
      amount = rr.score * total_dollars / 100
      CreditDistribution.create :user_id => rr.ratee_id, :project_id => project_id, :retro_id => rr.retro_id, :amount => amount unless amount == 0
    end
    
    self.status_id = STATUS_DISTRIBUTED
    self.save
  end
  
  def close
    return unless status_id == STATUS_INPROGRESS
    @user_hash = Hash.new
    RetroRating.delete_all :rater_id => -1, :retro_id => self.id
    RetroRating.delete_all :rater_id => -2, :retro_id => self.id
    
    return if retro_ratings.length == 0
    
    total_raters = retro_ratings.group_by{|retro_rating| retro_rating.rater_id}.length
    @confidence_hash = Hash.new
    
    retro_ratings.group_by{|retro_rating| retro_rating.ratee_id}.keys.each do |user_id|
      next if user_id < 0;
      @user_hash[user_id] = []
      @confidence_hash[user_id] = 0
    end

    puts("H: " + @user_hash.inspect)
    puts("total raters #{total_raters}")

    
    team_confidence_total = 0
    retro_ratings.each do |rr|
      puts("rr:#{rr.inspect}")
      next if rr.rater_id < 0;
      @user_hash[rr.ratee_id].push(rr.score * rr.confidence) unless ((rr.ratee_id == rr.rater_id) && (total_raters > 1))
      @confidence_hash[rr.ratee_id] += rr.confidence unless ((rr.ratee_id == rr.rater_id) && (total_raters > 1))
    end

    # @confidence_hash.each_value {|issues| team_confidence_total += issues.collect(&:points).sum }
    puts("confidence hash #{@confidence_hash.inspect}")
    
    puts("user hash: " + @user_hash.inspect)

    team_average_total = 0
    #rater_id -1 reserved for team average
    @user_hash.keys.each do |user_id|
      score = @user_hash[user_id].length == 0 ? 0 : @user_hash[user_id].sum.to_f / @confidence_hash[user_id]
# ore / @confidence_hash[user_id]
      RetroRating.create :rater_id => -1, :ratee_id => user_id, :score => score, :retro_id => self.id
      team_average_total = team_average_total + score
    end

    #rater_id -2 reserved for final distribution
    @user_hash.keys.each do |user_id|
      # puts("creating for:#{user_id}")
      score = @user_hash[user_id].length == 0 ? 0 : @user_hash[user_id].sum.to_f / @confidence_hash[user_id]
      # score = score / @confidence_hash[user_id]
      RetroRating.create :rater_id => -2, :ratee_id => user_id, :score => score * 100 / team_average_total, :retro_id => self.id
    end
    
    self.status_id = STATUS_COMPLETE
    self.save
    
    announce_close
  end
  
  #Sends notification to everyone in the retrospective that it's starting
  def announce_start
    @users = {}
    
    issues.each do |issue|
      @users.store issue.author_id, 1 unless @users.has_key? issue.author_id
      @users.store issue.assigned_to_id, 1 unless @users.has_key? issue.assigned_to_id
      issue.journals.each do |journal|
        @users.store journal.user_id, 1 unless @users.has_key? journal.user_id
      end
      issue.issue_votes.each do |iv|
        @users.store iv.user_id, 1 unless @users.has_key? iv.user_id
      end
    end
    
    admin = User.find(:first,:conditions => {:login => "admin"})
    @users.keys.each do |user_id|
      Notification.create :recipient_id => user_id,
                          :variation => 'retro_started',
                          :params => {:project => project}, 
                          :sender_id => admin.id,
                          :source_id => self.id    
    end
  end

  #Sends notification to everyone in the retrospective that it's ended
  def announce_close
    @users = Hash.new
    issue_votes.each do |issue_vote|
      @users[issue_vote.user_id] = 1 if issue_vote.vote_type == IssueVote::JOIN_VOTE_TYPE
    end
    
    admin = User.find(:first,:conditions => {:login => "admin"})
    
    @users.keys.each do |user_id|
      Notification.create :recipient_id => user_id,
                          :variation => 'retro_ended',
                          :params => {:project => project}, 
                          :sender_id => admin.id,
                          :source_id => self.id    
    end
  end
  
  #True when all team members in a retrospective have participated
  def all_in?
    rater_group = retro_ratings.group_by {|retro_rating| retro_rating.rater_id}
    ratee_group = retro_ratings.group_by {|retro_rating| retro_rating.ratee_id}
    return ratee_group.length <= rater_group.length
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

