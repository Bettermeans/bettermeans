module CommitRequestsHelper
  def active_requests(issue_id)
    
    unless @active_requests
      active = ARCondition.new(["response != ? AND response > -1 AND issue_id = ?",999,issue_id]) #TODO: In the future we might want to hide recinded requests by setting 999 to 1
      @active_requests = CommitRequest.find(:all, 
                                    :order => "created_on ASC",
                                    :conditions => active.conditions)
    end
    @active_requests
  end
  
  def render_request(request)
    content_tag(:div, "#{request.user_id} | #{request.issue_id}", :class => "commit_request_side", :id => "commit_request_side_#{request.id}")
  end  
  
  
  def authoring_from_id(issue, push_allowed, cr, options ={})
    @user = User.current
    @cr = cr
    
    logger.info(@cr.inspect)
    linebreak = "<br>==> "
    content = ''
    if (push_allowed == nil)
      push_allowed = @issue.push_allowed?(@user)
    end
    
    author = User.find(@cr.user_id)
    author_tag = (author.is_a?(User) && !author.anonymous?) ? link_to(h(author), :controller => 'account', :action => 'show', :id => author) : h(author || 'Anonymous')
    
    response = @cr.response
    
    responder = User.find(@cr.responder_id) unless (response == 0)
    responder_tag = (responder.is_a?(User) && !author.anonymous?) ? link_to(h(responder), :controller => 'account', :action => 'show', :id => responder) : h(responder || 'Anonymous')

    
    commitment_tag = l(:label_commitment) + ": " + day_label(@cr.days)
    if (@cr.user_id == @cr.responder_id) #User is the responder. This is someone taking this 
      content = l(options[:label] || :label_taken_by, :responder => responder_tag, :age => time_tag(@cr.created_on))                  
    elsif response > 3 #This was an offered request, pushed not pulled      
      #Add "offered by X to Y, Z hours ago"
      content = l(options[:label] || :label_offered_by, :author => author_tag, :age => time_tag(@cr.created_on), :responder => responder_tag)            
    else
      #Add "requested by X, Z hours ago"
      content = l(options[:label] || :label_requested_by, :author => author_tag, :age => time_tag(@cr.created_on))            
    end
    
    #We add the number of days, unless this was an offer that hasn't been accepted, or has been declined or recinded
    content << "<br/>" + commitment_tag unless response == 4 || response == 5 || response == 7 
    
    # 0- Request No response 1-Request recinded 2-Request Accepted 3-Request Declined 4-Offer no response 5-Offer recinded 6-Offer accepted 7-Offer Declined 8-Ownership Released
    #Adding response
    case response
      when 0 then 
        if push_allowed
          content << linebreak << link_to_remote(l(:button_request_commitment_accept), {:url => user_commit_request_path(:id => @cr.id, :format => :js, :user_id => @cr.user_id, :issue_id => issue, :response => 2, :responder_id => @user, :push_allowed => push_allowed), :method => 'put'}, {:id =>'cr_button', :class => 'icon icon-cr-accept'})
          content << " | " << link_to_remote(l(:button_request_commitment_decline), {:url => user_commit_request_path(:id => @cr.id, :format => :js, :user_id => @cr.user_id, :issue_id => issue, :response => 3, :responder_id => @user, :push_allowed => push_allowed), :method => 'put'}, {:id =>'cr_button', :class => 'icon icon-cr-decline'})
        end
      when 1 then content << linebreak << l(:label_recinded, :age => time_tag(@cr.updated_on))     
      when 2 then 
        unless (@cr.user_id == @cr.responder_id) #Unless someone taking this 
          content << linebreak << l(:label_accepted_by, :responder => responder_tag, :age => time_tag(@cr.updated_on))    
        end
      when 3 then 
        content << linebreak << l(:label_declined_by, :responder => responder_tag, :age => time_tag(@cr.updated_on))     
      when 4 then 
        if User.current.id == @cr.responder_id #if this offer is made to me
          content << linebreak << link_to(l(:button_request_commitment_accept), {:controller => 'commit_requests', :action => 'create_dialogue', :id => @cr.id, :format => :js, :user_id => @cr.user_id, :issue_id => issue, :response => 6, :responder_id => @user, :push_allowed => push_allowed, :button_action => 'update', :method => 'put', :class => 'icon icon-cr-accept', :label => l(:button_request_commitment_accept)}, {:id =>'cr_button', :class => 'lbOn icon icon-cr-accept'})
          content << " | " << link_to_remote(l(:button_request_commitment_decline), {:url => user_commit_request_path(:id => @cr.id, :format => :js, :user_id => @cr.user_id, :issue_id => issue, :response => 7, :responder_id => @user, :push_allowed => push_allowed), :method => 'put'}, {:id =>'cr_button', :class => 'icon icon-cr-decline'})
          
        elsif User.current.id == @cr.user_id #if this offer is BY me
          content << linebreak << link_to_remote(l(:button_request_commitment_withdraw), {:url => user_commit_request_path(:id => @cr.id, :format => :js, :user_id => @cr.user_id, :issue_id => issue, :response => 5, :responder_id => @cr.responder_id, :push_allowed => push_allowed), :method => 'put'}, {:id =>'cr_button_withdraw', :class => 'icon icon-cr-cancel'})
        end
      when 5 then content << linebreak << l(:label_recinded, :age => time_tag(@cr.updated_on))     
      when 6 then content << linebreak << l(:label_accepted, :age => time_tag(@cr.updated_on))     
      when 7 then content << linebreak << l(:label_declined, :age => time_tag(@cr.updated_on))     
      when 8 then content << linebreak << l(:label_released, :age => time_tag(@cr.updated_on))     
    end
    # logger.info("Authoring from id content #{content}")
    content << "<br>"
  end
  
  #Generates a link for pulling the request, depending on the response of the commit request
  def pull_link(user,issue,push_allowed)
    @issue = Issue.find(issue)
    @user = User.find(user)  
    @cr = CommitRequest.request(user,issue, @issue.assigned_to == @user)     
    @label = ''
    @response = ''
    @action = ''
    @class = ''
    
    logger.info("Generating pull link: ISSUE #{issue} USER #{user} ISSUEASSIGNED #{@issue.assigned_to} PUSH ALLOWED #{push_allowed} @CR: #{@cr.inspect unless @cr.nil?}")
    
    if (@issue.assigned_to == User.current) #If I own an issue, and I give it up it's marked as released      
      logger.info("Current user owns this issue")
      @label = l(:button_request_commitment_giveup)
      @response = 8
      @action = 'update'
      @class = 'icon-cr-cancel'
      @button_id = '_remove'
      
      if (@cr == nil) #Used for migration. Some issues have been assigned, but don't have commitment requests (before commitment requests were implemented!)
        logger.info("No existing commitment request. Creating first one")
        #Let's create a commitment request
        @cr = CommitRequest.new({:user_id => User.current.id, :response => 2, :responder_id => User.current.id, :created_on => @issue.created_on, :updated_on => @issue.updated_on, :issue_id => @issue.id})
        @cr.save
      end
    elsif (@cr == nil)
       #No commit requests from this user to this issue, 
       if push_allowed #they have the authority, they can take owneship
         @label = l(:button_request_commitment_take)
         @response = 2
         @action = 'create'
         @class = 'icon-cr-take'
       else #they can't just take this, they have to request
         @label = l(:button_request_commitment_request)
         @response = 0
         @action = 'create'         
         @class = 'icon-cr-request'
       end
    else
      case @cr.response
      when 0 then #Requested, but no response, option to take back request
        @label = l(:button_request_commitment_remove)
        @response = 1
        @action = 'update'
        @class = 'icon-cr-cancel'
        @button_id = '_remove'
      when 1..8 then #Requested and recinded before, or requested and denied, or requested and accepted so they can request again
          #No commit requests from this user to this issue, 
          if push_allowed #they have the authority, they can take owneship
            @label = l(:button_request_commitment_take) 
            @response = 2
            @action = 'create'
            @class = 'icon-cr-request'
          else #they can't just take this, they have to request
            @label = l(:button_request_commitment_request)
            @response = 0
            @action = 'create'
            @class = 'icon-cr-take'         
          end
      end
    end    
    
    @class = 'icon ' + @class

    @pull_content = ''
    @push_content = ''
    
    logger.info("READY TO MAKE BUTTONS #{@label}, #{@action}")

    if @action == 'create'
      @pull_content = link_to @label, 
              {:controller => 'commit_requests', :action => 'create_dialogue', :format => :js, :user_id => User.current.id, :issue_id => issue, :response => @response, :push_allowed => push_allowed, :button_action => 'create', :method => 'post', :class => @class, :label => @label}, 
                 {:id =>'cr_button', :class => @class + ' lbOn'}
    elsif @action == 'update'    
      @pull_content = link_to_remote @label, 
              {:url => user_commit_request_path(:id => @cr, :format => :js, :user_id => user, :issue_id => issue, :response => @response, :responder_id => user, :updated_on => @cr.updated_on, :created_on => @cr.created_on, :push_allowed => push_allowed), :method => 'put'}, 
                {:id =>'cr_button' + @button_id, :class => @class}      
    end   
    
    if push_allowed
      @label = l(:button_request_commitment_offer)
      @class = 'icon icon-cr-offer'
      @response = 4
      @push_content = link_to @label,
       {:controller => 'commit_requests', :action => 'select_user_dialogue', :format => :js, :id => @cr, :user_id => User.current.id, :issue_id => issue, :response => @response, :push_allowed => push_allowed, :class => @class, :label => @label}, 
       {:id =>'cr_push_button', :class => @class + ' lbOn'}
    end 
    
    @pull_content + " " + @push_content
    
  end  
end
