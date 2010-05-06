# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class TeamPoint < ActiveRecord::Base
  # fields do
  #   project_id :integer 
  #   author_id :integer 
  #   recipient_id :integer
  #   value :integer, :default => 1 #Value is -1 if this is a flag (or block or no confidence vote) should never really be 0
  #   created_on :datetime
  #   updated_on :datetime
  # end
  
  #Constants
  CORE_MEMBERSHIP_THRESHOLD = 0 #Threshold needed to be exceeded for someone to become a core member
  CORE_MEMBERSHIP_LOSS_THRESHOLD = -1 #Threshold needed to be reached for an existing member to lose their membership
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :project
  
  before_create :check_existing_points
  after_create :recalculate_core_membership
  after_update :recalculate_core_membership
  after_destroy :recalculate_core_membership
  
  #Re-assesses wether or not recipient is a core member of the team depending on total points
  def recalculate_core_membership
    total_points = TeamPoint.total(recipient, project)
    earned_core_membership = project.eligible_for_core?(recipient, :total_points => total_points)
    if earned_core_membership 
      #Send out an invitation if that person just earned their membersnip
      if total_points == CORE_MEMBERSHIP_THRESHOLD + 1 && value == 1 #only invite if total points is 1 more than threshold, and current value is one (i.e. we're not falling from 2 to 1). We don't want them getting an invitation everytime their total changes
        TeamOffer.create! :project_id => project_id, :recipient_id => recipient_id, :author_id => author_id, :variation => TeamOffer::VARIATION_INVITATION
        #TODO: Create notification and send it to author letting them know that an invitation has been sent on their behalf
      end unless recipient.core_member_of?(project)      
    else
      #Remove user from core membership  
      recipient.drop_from_core(project)
    end
  end
  
  #Total team points for this user for this project
  #NOTE: this code is repected in projects_helper.endorse_links for performance sake!
  def self.total(user, project, options={})
    sum = 0
    TeamPoint.find(:all, :include => [:author, {:author => [:core_memberships]}], :conditions => {:project_id => project, :recipient_id => user}).each do |t|
      t.author.core_memberships.each do |m|
        if m.project_id == project.id || m.project_id == project.parent_id #only calculate points given by other core members on this team, or the parent team
          sum = sum + t.value 
          break #we break because we don't want to double count if author is both a core member of current project AND parent project
        end
      end
    end
    sum
  end
  
  def check_existing_points
    #First we check that no other votes exist from this user, to that user for the same project
    existing_vote = TeamPoint.find(:first, :conditions => {:author_id => self.author_id, :recipient_id => self.recipient_id, :project_id => self.project_id})
    logger.info(existing_vote.inspect)
    return true if existing_vote.nil? #If no other team point exists we let this one get created    
    
    delete_team_point(existing_vote.id)  if existing_vote.value != self.value #If another vote exists of a different value, we delete it (as both votes cancel each other),

   #If another vote exists, and it's of the same value, we don't do anything (this is a forbidden action)
   false
    
  end
  
  private
  
  def delete_team_point(team_point_id)
    dbconn = self.class.connection_pool.checkout
    dbconn.transaction do
      dbconn.execute("delete from team_points where id = '#{team_point_id}'")
    end
    self.class.connection_pool.checkin(dbconn)
  end
  
end


# == Schema Information
#
# Table name: team_points
#
#  id           :integer         not null, primary key
#  project_id   :integer
#  author_id    :integer
#  recipient_id :integer
#  created_on   :datetime
#  updated_on   :datetime
#  value        :integer         default(1)
#

