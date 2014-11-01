# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class Retro < ActiveRecord::Base

  include ActionController::UrlWriter
  include ActionView::Helpers

  STATUS_INPROGRESS = 1
  STATUS_COMPLETE = 2 #is closed, but credits haven't been distributed yet
  STATUS_DISTRIBUTED = 3 #credits have been distributed
  STATUS_DISPUTED = 9
  NOT_STARTED_ID = -1 #is for issues that haven't been started yet
  NOT_NEEDED_ID = -2 #is for issues that don't need a retrospective b/c only one person worked on them (e.g gifts)
  NOT_ENABLED_ID = -5 #is for issues that don't need a retrospective b/c credits are disabled for their workstream

  #
  # The following two statuses are for issues that aren't part of a
  # retrospective but whose credits are given when credits are
  # distributed in the next retrospective
  #
  NOT_GIVEN_AND_NOT_PART_OF_RETRO = -3
  GIVEN_BUT_NOT_PART_OF_RETRO = -4

  belongs_to :project
  has_many :issues
  has_many :journals, :through => :issues
  has_many :issue_votes, :through => :issues
  has_many :retro_ratings
  has_many :credit_distributions

  def ended? # cover_me heckle_me
    return status_id == STATUS_COMPLETE || status_id == STATUS_DISTRIBUTED
  end

  #For closed retrospectives
  def distribute_credits # spec_me cover_me heckle_me
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

    #
    # Distribute the hourly credits
    # They weren't a part of this retrospective but are distributed w/
    # the other credits in this retrospective.
    #
    hourly_issues = project.issues.find(:all, :conditions => ["retro_id=? AND hourly_type_id IS NOT NULL", Retro::NOT_GIVEN_AND_NOT_PART_OF_RETRO])

    hourly_issues.each do |hourly|
      hourly.give_credits
    end

    project.issues.update_all("retro_id=#{Retro::GIVEN_BUT_NOT_PART_OF_RETRO}",
                              "retro_id=#{Retro::NOT_GIVEN_AND_NOT_PART_OF_RETRO} AND hourly_type_id IS NOT NULL")

    self.status_id = STATUS_DISTRIBUTED
    self.save
  end

  def close # spec_me cover_me heckle_me
    return unless status_id == STATUS_INPROGRESS
    calculate_ratings
    announce_close
    self.status_id = STATUS_COMPLETE
    self.save
    self.distribute_credits
  end

  def calculate_ratings # spec_me cover_me heckle_me
    @user_hash = Hash.new
    @user_final = Hash.new #final distribution
    @user_self = Hash.new #self assessment
    @user_total_bias = Hash.new #total bias
    @confidence_hash = Hash.new
    @confidence_array = [] #stores confidence that each rater voted with

    RetroRating.delete_all :rater_id => RetroRating::TEAM_AVERAGE , :retro_id => self.id
    RetroRating.delete_all :rater_id => RetroRating::FINAL_AVERAGE , :retro_id => self.id
    RetroRating.delete_all :rater_id => RetroRating::SELF_BIAS , :retro_id => self.id
    RetroRating.delete_all :rater_id => RetroRating::SCALE_BIAS , :retro_id => self.id

    return if retro_ratings.length == 0

    total_raters = retro_ratings.group_by{|retro_rating| retro_rating.rater_id}.length

    retro_ratings.group_by{|retro_rating| retro_rating.ratee_id}.keys.each do |user_id|
      next if user_id < 0;
      @user_hash[user_id] = []
      @confidence_hash[user_id] = 0
      @confidence_array[user_id] = 0
    end

    team_confidence_total = 0
    retro_ratings.each do |rr|
      next if rr.rater_id < 0;
      @user_hash[rr.ratee_id].push(rr.score * rr.confidence) unless ((rr.ratee_id == rr.rater_id) && (total_raters > 1))
      @confidence_hash[rr.ratee_id] += rr.confidence unless ((rr.ratee_id == rr.rater_id) && (total_raters > 1))

      if (rr.ratee_id == rr.rater_id)
        @user_self[rr.ratee_id] = rr.score
        @confidence_array[rr.rater_id] = rr.confidence
        @user_total_bias[rr.rater_id] = 0 #initializing for later
      end
    end

    #team averages
    team_average_total = 0
    @user_hash.keys.each do |user_id|
      score = @user_hash[user_id].length == 0 ? 0 : @user_hash[user_id].sum.to_f / @confidence_hash[user_id]
      RetroRating.create :rater_id => RetroRating::TEAM_AVERAGE, :ratee_id => user_id, :score => score, :retro_id => self.id, :confidence => @confidence_array[user_id]
      team_average_total = team_average_total + score
    end

    #final distribution and self bias
    @user_hash.keys.each do |user_id|
      score = @user_hash[user_id].length == 0 ? 0 : @user_hash[user_id].sum.to_f / @confidence_hash[user_id]
      score = score * 100 / team_average_total
      self_bias = (@user_self[user_id] - score) * @confidence_array[user_id] / 100 unless @user_self[user_id].nil? || @user_self[user_id].nan?

      @user_final[user_id] = score
      RetroRating.create :rater_id => RetroRating::FINAL_AVERAGE, :ratee_id => user_id, :score => score, :retro_id => self.id, :confidence => @confidence_array[user_id]
      RetroRating.create :rater_id => RetroRating::SELF_BIAS, :ratee_id => user_id, :score => self_bias, :retro_id => self.id, :confidence => @confidence_array[user_id] unless self_bias.nil? || self_bias.nan?
    end

    #total bias points
    retro_ratings.each do |rr|
      next if rr.rater_id < 0;
      @user_total_bias[rr.rater_id] += (rr.score -  @user_final[rr.ratee_id]).abs
    end

    @user_total_bias.keys.each do |user_id|
      RetroRating.create :rater_id => RetroRating::SCALE_BIAS, :ratee_id => user_id, :score => @user_total_bias[user_id] * @confidence_array[user_id] / 100, :retro_id => self.id, :confidence => @confidence_array[user_id] unless @user_total_bias[user_id].nan?
    end
  end

  #Sends notification to everyone in the retrospective that it's starting
  def announce_start # spec_me cover_me heckle_me
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
                          :source_type => "Retro",
                          :source_id => self.id
    end
  end

  #Sends notification to everyone in the retrospective that it's ended
  def announce_close # spec_me cover_me heckle_me
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
                          :source_type => "Retro",
                          :source_id => self.id
    end
  end

  #True when all team members in a retrospective have participated
  def all_in? # spec_me cover_me heckle_me
    rater_group = retro_ratings.group_by {|retro_rating| retro_rating.rater_id}
    ratee_group = retro_ratings.group_by {|retro_rating| retro_rating.ratee_id}
    return (ratee_group.length <= rater_group.length) && (rater_group.length != 0)
  end
end



