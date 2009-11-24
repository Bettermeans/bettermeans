class TeamOffer < ActiveRecord::Base
  fields do
    project_id :integer 
    author_id :integer #author of offer/request
    recipient_id :integer #recipient of offer/request
    response :integer, :default => 0 #-1 disabled #0 no response #1 recinded/withdrawn #2 accepted #3 declined
    variation :integer #0 offer #1 request
    expires :datetime, :default =>  Time.now.advance(:months => 1)
    author_note :text #note sent by author
    recipient_note :text #note sent by recipient
    created_on :datetime
    updated_on :datetime    
  end
  
  # Team offer response
  RESPONSE_DISABLED = -1
  RESPONSE_NONE = 0
  RESPONSE_WITHDRAWN = 1
  RESPONSE_ACCEPTED = 2
  RESPONSE_DECLINED = 3

  # Team offer types
  VARIATION_INVITATION = 0
  VARIATION_REQUEST = 1
  
  validates_presence_of :response
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :project
  
  acts_as_event :title => Proc.new {|o| "#{o.variation_description} #{l(:label_to_join_core_team_of, :project => o.project.name)} #{o.response_type_description}" },
                :description => :long_description,
                :author => :author,
                :type => 'team-offer',
                :url => Proc.new {|o| {:controller => 'projects', :action => 'team', :id => o.project}}
    
  acts_as_activity_provider :type => 'team_offers',
                            :author_key => :author_id,
                            :permission => :view_project,
                            :find_options => {:include => [:project, :author, :recipient]}
  
  def offer?
    variation == VARIATION_INVITATION
  end
  
  def request?
    variation == VARIATION_REQUEST
  end
  
  def accepted?
    response == RESPONSE_ACCEPTED
  end
  
  def withdrawn?
    response == RESPONSE_WITHDRAWN
  end
  
  def declined?
    response == RESPONSE_DECLINED
  end
  
  def response?
    response != RESPONSE_NONE
  end
  
  def disabled?
    response == RESPONSE_DISABLED
  end
  
  #Describes the type of offer (e.g. offer, or request, and wether it's being accepted, declined, withdrawn...etc.)
  def short_description
    content = "#{variation_description} #{response_type_description}"
  end
  
  def variation_description
    content = ''
    case variation
      when VARIATION_INVITATION then content << l(:label_invitation)
      when VARIATION_REQUEST then content << l(:label_request)
    end        
  end
  
  def response_type_description
    content = ''
    case response
      when RESPONSE_ACCEPTED then content << l(:label_accepted)
      when RESPONSE_DECLINED then content << l(:label_declined)
      when RESPONSE_NONE then content << l(:label_sent)
      when RESPONSE_WITHDRAWN then content << l(:label_withdrawn)
    end        
  end
  
  def recipient_tag
    recipient_tag = recipient.nil? ? nil : recipient.name  
  end

  def author_tag
    author_tag = author.name
  end
  
  #Describes what last happened for this record (e.g. accepted by who after who responded, and when)
  def long_description    
    content = ''
    line_break = '. '
    
    content = "#{author_tag} #{l(:label_sent)} #{variation_description} #{line_break}"
    content << "#{recipient_tag} #{response_type_description}" unless response < 1    
  end
  
  #Used to notify author of response
  def response_description
    content = "#{l(:label_your)} #{variation_description} #{l(:label_to)} #{recipient_tag} #{l(:label_to_join_core_team_of, :project => project)} #{l(:label_was)} #{response_type_description}"
  end
  
  #Used to notify recipient of invitation (or request)
  def sending_description
    content = ''
    case variation
      when VARIATION_INVITATION then content << l(:label_sending_team_invitation, :author => author_tag, :project => self.project.name)
      when VARIATION_REQUEST then content << l(:label_sending_team_request, :author => author_tag, :project => self.project.name)
    end
  end
  
  #note 
  def recipient_note_description
    unless recipient_note.nil?
      content = "#{l(:label_note_from, :author => recipient.firstname)}: #{recipient_note}"
    end
  end
  
  def author_note_description
    unless author_note.nil?
      content = "#{l(:label_note_from, :author => author.firstname)}: #{author_note}"
    end
  end
  
  #TODO move this somewhere global
  # Takes a hash, and turns it into a notification params string (to pass into params for notification)
  def hash_to_param_string(h)
    content = ''
    h.each do |a|
      unless a[1].nil?
        content << ":" << a[0].to_s << " => '" << a[1].to_s << "', "
      else
        content << ":" << a[0].to_s << " => nil, "
      end
    end
    content.chop.chop #removing last 2 characters
  end
  
  def before_create
    #If this is a request, then find out who the administrator for this project is, and set them as the recipient of this request
  end
  
  #Send notification of request or invitation to recipient
  def after_create
     Notification.create! :recipient_id => recipient_id,
                          :variation => "team_offer",                        
                          :params => "#{hash_to_param_string(self.attributes)}, :sender_id => #{author_id}, :variation_description => '#{variation_description.downcase!}', :project => '#{self.project.name}', :body => '#{sending_description}.<br>#{author_note_description}'",  
                          :source_id => id
                          
    #TODO: If this is a request, send notifications to all core team members for that project
  end
  
  #send notification message to author with recipient's response
  def after_update
    Notification.create! :recipient_id => author_id,
                        :variation => 'message',                        
                        :params => ":subject => '#{short_description}', :message => '#{response_description}. #{recipient_note_description}', :sender_id => #{recipient_id}",  
                        :source_id => id     unless withdrawn? || disabled? #don't send if the update is about withdrawing
                        
    #TODO: If this is a request, we delete all notifications sent around this request (or disable them)
    #TODO: If this is an offer that was accepted, we delete all other offers to this person for that team
  end
  
  
end
