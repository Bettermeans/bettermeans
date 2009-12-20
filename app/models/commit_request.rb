# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

# 0- Request No response 1-Request recinded 2-Request Accepted 3-Request Declined 4-Offer no response 5-Offer recinded 6-Offer accepted 7-Offer Declined 8-Ownership Released


class CommitRequest < ActiveRecord::Base
  belongs_to :user #author of the request/offer
  belongs_to :responder, :class_name => 'User', :foreign_key => 'responder_id'
  belongs_to :issue  
  
  after_update :update_issue
  
  acts_as_event :title => Proc.new {|o| "#{o.short_description} #{l(:label_for)} #{o.issue.tracker} ##{o.issue.id}: #{o.issue.subject}" },
                :description => :long_description,
                :author => :actor,
                :type => 'cr-note',
                :url => Proc.new {|o| {:controller => 'issues', :action => 'show', :id => o.issue.id}}
    
  acts_as_activity_provider :type => 'commit_requests',
                            :author_key => :user_id, #BUGBUG: activity won't show for responder here. somehow we need both user_id and responder_id
                            :permission => :view_issues,
                            :timestamp => "#{table_name}.updated_on",
                            :find_options => {:include => [{:issue => :project}, :user]}                            
  
  #True if user has requested commitment to this ussue
  def self.committed?(user, issue)
    ! (find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue]) == nil)
  end
  
  #Returns person who last took an action on this cr
  def actor
    case response
      when 0 then user
      when 1 then user
      when 2 then responder
      when 3 then responder
      when 4 then user
      when 5 then user
      when 6 then responder
      when 7 then responder
      when 8 then user
    end
  end
  
  def responder
    responder_id.nil? ? nil : User.find(responder_id)
  end

  #Returns request for current user and issue
  def self.request(user, issue, userowned)
    if (userowned) #user owns this issue, we're looking for the commit request that he took this issue with (either accepting an offer, taking one)
      @cr = find(:first, :conditions => ["responder_id = ? AND issue_id = ? AND (response = 2 or response = 6) ", user, issue], :order => "updated_on DESC")
    else
      @cr = find(:first, :conditions => ["user_id = ? AND issue_id = ? AND response > -1", user, issue], :order => "updated_on DESC")
    end
  end
  
  def project
    issue.respond_to?(:project) ? issue.project : nil
  end
  
  # 0- Request No response 1-Request recinded 2-Request Accepted 3-Request Declined 4-Offer no response 5-Offer recinded 6-Offer accepted 7-Offer Declined 8-Ownership Released
  #Describes the type of request (e.g. offer, or request, and wether it's being accepted, declined, withdrawn...etc.)
  def short_description
    content = ''
    
    case response
      when 0 then content << l(:label_ownership_requested)
      when 1 then content << l(:label_ownership_request_recinded)
      when 2 then 
        if (user_id == responder_id) #User is the responder. This is someone taking this 
          content << l(:label_ownership_taken)      
        else
          content << l(:label_ownership_request_accepted)
        end
      when 3 then content << l(:label_ownership_request_declined)                
      when 4 then content << l(:label_ownership_offered)
      when 5 then content << l(:label_ownership_offer_withdrawn)
      when 6 then content << l(:label_ownership_offer_accepted)
      when 7 then content << l(:label_ownership_offer_declined)                
      when 8 then content << l(:label_ownership_released)                
    end    
  end
  
  #Describes what last happened for this record (e.g. accepted by who after who responded)
  def long_description    
    content = ''
    line_break = '. '
    user_tag = user.name
    responder_tag = responder.nil? ? nil : responder.name
    
    commitment_tag = l(:label_commitment) + ": " + day_label
    
    case response
      when 0 then content << l(:label_ownership_requested) << line_break << commitment_tag
      when 1 then content << l(:label_ownership_request_recinded)
      when 2 then 
        if (user_id == responder_id) #User is the responder. This is someone taking this 
          content << l(:label_ownership_taken) << line_break << commitment_tag
        else
          content << l(:label_ownership_request_accepted_from, :user => user_tag)
        end
      when 3 then content << l(:label_ownership_request_declined_from, :user => user_tag)                
      when 4 then content << l(:label_ownership_offered_to, :user => responder_tag)
      when 5 then content << l(:label_ownership_offer_withdrawn_to, :user => responder_tag)
      when 6 then content << l(:label_ownership_offer_accepted_from, :user => user_tag) << line_break << commitment_tag
      when 7 then content << l(:label_ownership_offer_declined_from, :user => user_tag)                
      when 8 then content << l(:label_ownership_released)                
    end    
  end
  
  # Generates a label from number of days of a commitment
  def day_label
    CommitRequest.day_label days
  end 
  
  def self.day_label(days)
    case days
      when -1 then l(:label_not_sure)
      when 0 then l(:label_same_day)
      when 1 then "1 " + l(:label_day)
      when 2..100 then String(days) + " " + l(:label_day_plural)
    end
  end
  
  def update_issue

    case response
    when 1 #request recinded
      Notification.recind('commit_request', issue.id, user_id)
    when 2 #somebody is accepting someone else's request for this issue
      #Updating issue status to committed if user_id is current user_id (and change response type to 1 for accepted)
      @user = User.find(user_id)
      issue.assigned_to = @user
      issue.expected_date = Time.new() + 3600*24*days unless days < 0
      issue.status = IssueStatus.assigned
      issue.save
      
      #Add requester as a contributor to that project
      user.add_to_project(issue.project, Role::BUILTIN_CONTRIBUTOR) unless user.core_member_of?(issue.project)
      
      CommitRequest.update_notifications_and_commit_requests(user_id,issue,true,false)
      logger.info("Inspecting issue: #{issue.inspect}")
    when 3 #request declined
      CommitRequest.update_notifications_and_commit_requests(responder_id,issue,false,false)
    when 5 #offer recinded
      Notification.recind('commit_request', issue.id, responder_id)
    when 6 #somebody is accepting an offer for this issue
      #Updating issue status to committed if user_id is current user_id (and change response type to 1 for accepted)
      @user = User.find(responder_id)
      issue.assigned_to = @user
      issue.expected_date = Time.new() + 3600*24*days unless days < 0
      issue.status = IssueStatus.assigned
      issue.save
      
      
      #Add responder as a contributor to that project
      responder.add_to_project(issue.project, Role::BUILTIN_CONTRIBUTOR) unless responder.core_member_of?(issue.project)
      
      CommitRequest.update_notifications_and_commit_requests(responder_id,issue,true,false)
    when 7 #declining an offer
      #Notify offerer that their offer has been declined
      CommitRequest.update_notifications_and_commit_requests(User.current.id,issue,false,false)

    when 8 #somebody is releasing this issue
      issue.assigned_to = nil
      issue.expected_date = nil
      issue.status = IssueStatus.default
      issue.save
      CommitRequest.update_notifications_and_commit_requests(User.current.id,issue,false,true)
    end 
    
  end
  
  # 0- Request No response 1-Request recinded 2-Request Accepted 3-Request Declined 4-Offer no response 5-Offer recinded 6-Offer accepted 7-Offer Declined 8-Ownership Released
  def self.update_notifications_and_commit_requests(user_id,issue,accepted,released)
    @user = User.find(user_id)
    issue.commit_requests.each do |cr|
      
      #Deal with duplicate offers/requests made to/by same user that was just accepted/declined
      if cr.responder_id == @user.id && cr.response == 4 # Update all offers to this user for this issue (i.e. if I accept one offer, then I've accepted them all, if I decline one offer, then I've declined them all) 
        cr.response = accepted ? 6 : 7
        cr.save
      elsif cr.user_id == @user.id && cr.response == 0 #Update all requests from this user for this issue (i.e. if I requested it multiple times)
        cr.response = accepted ? 2 : 3
        cr.responder_id = User.current.id
        cr.save
      end  
      
      #Deal with offers and requests made on this issue by other users
      case cr.response
        when 0,4 then
          if accepted #all oustanding requests and offers are disabled, since another request has just been accepted
            cr.response = cr.response - 20
            cr.save
          end
      end
      
      #just released, we reactivate all open requests and offers
      if released && cr.response < 0
        cr.response = cr.response + 20
        cr.save
      end
    end            
      
    # Update all notifications to this user about this issue (all notifications to me, regarding this issue being offered to me are archived)
    @user.notifications.allactive.each do |n|
      logger.info("iterating through users notifications object #{n.id} #{n.source_id} issue #{issue.id}")
      if n.source_id == issue.id && n.variation.match(/^commit_request/) #TODO: create a better query so I'm not iterating through records I don't need here
        n.state = 1
        n.save
        logger.info("Deactivated")
      end
    end
  
    # Update all notifications (disable all notifications about offers for this issue for other users)
    Notification.deactivate_all('commit_request', issue.id) if accepted
    
    # If this is an issue that's being released we activate all notifications for it
    Notification.activate_all('commit_request', issue.id) if released
    
  end
  
  
  
end


# == Schema Information
#
# Table name: commit_requests
#
#  id           :integer         not null, primary key
#  user_id      :integer         default(0), not null
#  issue_id     :integer         default(0), not null
#  days         :integer         default(0)
#  responder_id :integer         default(0)
#  response     :integer         default(0), not null
#  created_on   :datetime
#  updated_on   :datetime
#

