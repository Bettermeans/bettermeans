# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#


class CommitRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue  
  
  acts_as_event :title => Proc.new {|o| "#{o.short_description} #{l(:label_for)} #{o.issue.tracker} ##{o.issue.id}: #{o.issue.subject}" },
                :description => :long_description,
                :author => :actor,
                :type => 'cr-note',
                :url => Proc.new {|o| {:controller => 'issues', :action => 'show', :id => o.issue.id}}
    
  acts_as_activity_provider :type => 'commit_requests',
                            :author_key => :user_id,
                            :permission => :view_issues,
                            :find_options => {:include => [{:issue => :project}, :user]}                            
  
  #True if user has requested commitment to this ussue
  def self.committed?(user, issue)
    ! (find(:first, :conditions => ["user_id = ? AND issue_id = ?", user, issue]) == nil)
  end
  
  #Returns person who last took an action on this cr
  def actor
    logger.info("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #{response.inspect}")
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
    case days
      when -1 then l(:label_not_sure)
      when 0 then l(:label_same_day)
      when 1 then "1 " + l(:label_day)
      when 2..100 then String(days) + " " + l(:label_day_plural)
    end
  end      
  
  
end
