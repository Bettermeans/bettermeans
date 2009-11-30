class TeamPoint < ActiveRecord::Base
  fields do
    project_id :integer 
    author_id :integer 
    recipient_id :integer
    value :integer, :default => 1 #Value is -1 if this is a flag (or block or no confidence vote) should never really be 0
    timestamps
  end
  
  #Constants
  CORE_MEMBERSHIP_THRESHOLD = 0 #Threshold needed to be exceeded for someone to become a core member
  CORE_MEMBERSHIP_LOSS_THRESHOLD = -1 #Threshold needed to be reached for an existing member to lose their membership
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :project
  
  after_create :recalculate_core_membership
  after_update :recalculate_core_membership
  after_destroy :recalculate_core_membership
  
  #Re-assesses wether or not recipient is a core member of the team depending on total points
  def recalculate_core_membership
    total_points = project.team_points_for(recipient)
    earned_core_membership = (total_points > CORE_MEMBERSHIP_THRESHOLD) || (total_points > CORE_MEMBERSHIP_LOSS_THRESHOLD && recipient.core_member_of?(project)) #More than zero to initiate, but if user is already a member they stay if their total is 0
    if earned_core_membership 
      #Add user as core member (add core member role, and remove contributor role for this member)
      recipient.add_to_core(project) unless recipient.core_member_of?(project)
    else
      #Remove user from core membership  
      recipient.drop_from_core(project)
    end
  end
  
  #Total team points for this user for this project
  def self.total(user, project, options={})
    sum = 0
    TeamPoint.find(:all, :include => [:author, {:author => [:core_memberships]}], :conditions => {:project_id => project, :recipient_id => user}).each do |t|
      logger.info(t.author.name)
      t.author.core_memberships.each do |m|
        sum = sum + t.value if m.project_id == project #only calculate points given by other core members on this team!
      end
    end
    sum
  end
end
