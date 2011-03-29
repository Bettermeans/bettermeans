ActionController::Routing::Routes.draw do |map|

  map.resources :help_sections
  map.resources :reputations
  map.resources :credit_distributions
  map.resources :quotes

  # map.resources :retro_ratings
  # 
  # map.resources :retros

  
  # map.resources :projects
  
  # map.connect 'commit_requests/createdialgoue', :action => 'createdialogue', :controller => 'commit_requesets'
  

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  map.connect 'accounts/rpx_token',:controller => 'account', :action => 'rpx_token'
  
  
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help' #What's this?
  map.connect 'help/:id', :controller => 'help', :action => 'show'
  
  map.connect 'time_entries/:id/edit', :action => 'edit', :controller => 'timelog'
  map.connect 'projects/:project_id/time_entries/new', :action => 'edit', :controller => 'timelog'
  map.connect 'projects/:project_id/issues/:issue_id/time_entries/new', :action => 'edit', :controller => 'timelog'
  
  map.with_options :controller => 'timelog' do |timelog|
    timelog.connect 'projects/:project_id/time_entries', :action => 'details'
    
    timelog.with_options :action => 'details', :conditions => {:method => :get}  do |time_details|
      time_details.connect 'time_entries'
      # time_details.connect 'time_entries.:format'
      time_details.connect 'issues/:issue_id/time_entries'
      # time_details.connect 'issues/:issue_id/time_entries.:format'
      # time_details.connect 'projects/:project_id/time_entries.:format'
      time_details.connect 'projects/:project_id/issues/:issue_id/time_entries'
      # time_details.connect 'projects/:project_id/issues/:issue_id/time_entries.:format'
    end
    timelog.connect 'projects/:project_id/time_entries/report', :action => 'report'
    timelog.with_options :action => 'report',:conditions => {:method => :get} do |time_report|
      time_report.connect 'time_entries/report'
      # time_report.connect 'time_entries/report.:format'
      # time_report.connect 'projects/:project_id/time_entries/report.:format'
    end

    timelog.with_options :action => 'edit', :conditions => {:method => :get} do |time_edit|
      time_edit.connect 'issues/:issue_id/time_entries/new'
    end
      
    timelog.connect 'time_entries/:id/destroy', :action => 'destroy', :conditions => {:method => :post}
  end
  
  map.connect 'projects/:id/wiki', :controller => 'wikis', :action => 'edit', :conditions => {:method => :post}
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => :get}
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => :post}
  map.with_options :controller => 'wiki' do |wiki_routes|
    wiki_routes.with_options :conditions => {:method => :get} do |wiki_views|
      wiki_views.connect 'projects/:id/wiki/:page', :action => 'special', :page => /page_index|date_index|export/i
      wiki_views.connect 'projects/:id/wiki/:page', :action => 'index', :page => nil
      wiki_views.connect 'projects/:id/wiki/:page/edit', :action => 'edit'
      wiki_views.connect 'projects/:id/wiki/:page/rename', :action => 'rename'
      wiki_views.connect 'projects/:id/wiki/:page/history', :action => 'history'
      wiki_views.connect 'projects/:id/wiki/:page/diff/:version/vs/:version_from', :action => 'diff'
      wiki_views.connect 'projects/:id/wiki/:page/annotate/:version', :action => 'annotate'
    end
    
    wiki_routes.connect 'projects/:id/wiki/:page/:action', 
      :action => /edit|rename|destroy|preview|protect/,
      :conditions => {:method => :post}
  end
  
  map.with_options :controller => 'messages' do |messages_routes|
    messages_routes.with_options :conditions => {:method => :get} do |messages_views|
      messages_views.connect 'boards/:board_id/topics/new', :action => 'new'
      messages_views.connect 'boards/:board_id/topics/:id', :action => 'show'
      messages_views.connect 'boards/:board_id/topics/:id/edit', :action => 'edit'
    end
    messages_routes.with_options :conditions => {:method => :post} do |messages_actions|
      messages_actions.connect 'boards/:board_id/topics/new', :action => 'new'
      messages_actions.connect 'boards/:board_id/topics/:id/replies', :action => 'reply'
      messages_actions.connect 'boards/:board_id/topics/:id/:action', :action => /edit|destroy/
    end
  end
  
  map.with_options :controller => 'invitations' do |invitations_routes|
    invitations_routes.with_options :conditions => {:method => :get} do |invitations_views|
      invitations_views.connect 'invitations/:id', :action => 'accept'
    end
    invitations_routes.with_options :conditions => {:method => :post} do |invitations_actions|
      invitations_actions.connect 'projects/:project_id/invitations/:id/:action', :action => /destroy|resend/
    end
  end
  
  map.with_options :controller => 'email_updates' do |email_updates_routes|
    email_updates_routes.with_options :conditions => {:method => :get} do |invitations_views|
      email_updates_routes.connect 'email_updates/activate', :action => 'activate'
    end
  end
  
  map.resources :email_updates
  
  
  
  
  map.with_options :controller => 'boards' do |board_routes|
    board_routes.with_options :conditions => {:method => :get} do |board_views|
      board_views.connect 'projects/:project_id/boards', :action => 'index'
      board_views.connect 'projects/:project_id/boards/new', :action => 'new'
      board_views.connect 'projects/:project_id/boards/:id', :action => 'show'
      # board_views.connect 'projects/:project_id/boards/:id.:format', :action => 'show'
      board_views.connect 'projects/:project_id/boards/:id/edit', :action => 'edit'
    end
    board_routes.with_options :conditions => {:method => :post} do |board_actions|
      board_actions.connect 'projects/:project_id/boards', :action => 'new'
      board_actions.connect 'projects/:project_id/boards/:id/:action', :action => /edit|destroy/
    end
  end
  
  map.with_options :controller => 'documents' do |document_routes|
    document_routes.with_options :conditions => {:method => :get} do |document_views|
      document_views.connect 'projects/:project_id/documents', :action => 'index'
      document_views.connect 'projects/:project_id/documents/new', :action => 'new'
      document_views.connect 'documents/:id', :action => 'show'
      document_views.connect 'documents/:id/edit', :action => 'edit'
    end
    document_routes.with_options :conditions => {:method => :post} do |document_actions|
      document_actions.connect 'projects/:project_id/documents', :action => 'new'
      document_actions.connect 'documents/:id/:action', :action => /destroy|edit/
    end
  end
  
  map.with_options :controller => 'issues' do |issues_routes|
    issues_routes.with_options :conditions => {:method => :get} do |issues_views|
      issues_views.connect 'issues', :action => 'index'
      issues_views.connect 'issues/datadump.:format', :action => 'datadump'
      issues_views.connect 'issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues', :action => 'index'
      issues_views.connect 'projects/:project_id/issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues/new', :action => 'new'
      issues_views.connect 'projects/:project_id/issues/gantt', :action => 'gantt'
      issues_views.connect 'projects/:project_id/issues/calendar', :action => 'calendar'
      issues_views.connect 'projects/:project_id/issues/:copy_from/copy', :action => 'new'
      issues_views.connect 'issues/:id/edit', :action => 'edit', :id => /\d+/
      issues_views.connect 'issues/:id/move', :action => 'move', :id => /\d+/
      issues_views.connect 'issues/:id/show', :action => 'show', :id => /\d+/
    end
    issues_routes.with_options :conditions => {:method => :post} do |issues_actions|
      issues_actions.connect 'projects/:project_id/issues', :action => 'new'
      issues_actions.connect 'issues/:id/quoted', :action => 'reply', :id => /\d+/
      issues_actions.connect 'issues/:id/:action', :action => /edit|move|destroy|start|finish|release|cancel|restart|prioritize|agree|disagree|estimate|accept|reject|join|leave|add_team_member|update_tags/, :id => /\d+/
      issues_actions.connect 'issues/:container_id/attachments/create', :controller => 'attachments', :action => 'create'
    end
  end
  
  map.with_options  :controller => 'issue_relations', :conditions => {:method => :post} do |relations|
    relations.connect 'issues/:issue_id/relations/:id', :action => 'new'
    relations.connect 'issues/:issue_id/relations/:id/destroy', :action => 'destroy'
  end
  
  map.with_options :controller => 'reports', :action => 'issue_report', :conditions => {:method => :get} do |reports|
    reports.connect 'projects/:id/issues/report'
    reports.connect 'projects/:id/issues/report/:detail'
  end
  
  map.with_options :controller => 'news' do |news_routes|
    news_routes.with_options :conditions => {:method => :get} do |news_views|
      news_views.connect 'news', :action => 'index'
      news_views.connect 'projects/:project_id/news', :action => 'index'
      news_views.connect 'projects/:project_id/news.:format', :action => 'index'
      news_views.connect 'news.:format', :action => 'index'
      news_views.connect 'projects/:project_id/news/new', :action => 'new'
      news_views.connect 'news/:id', :action => 'show'
      news_views.connect 'news/:id/edit', :action => 'edit'
    end
    news_routes.with_options do |news_actions|
      news_actions.connect 'projects/:project_id/news', :action => 'new'
      news_actions.connect 'news/:id/edit', :action => 'edit'
      news_actions.connect 'news/:id/destroy', :action => 'destroy'
    end
  end
  
  map.connect 'projects/:id/members/new', :controller => 'members', :action => 'new'
    
    map.resources :users do |users|
      users.resources :mails, :collection => { :delete_selected => :post }
    end
  
  map.with_options :controller => 'users' do |users|
    users.with_options :conditions => {:method => :get} do |user_views|
      user_views.connect 'users', :action => 'index'
      user_views.connect 'users/:id', :action => 'show', :id => /\d+/
      user_views.connect 'users/new', :action => 'add'
      user_views.connect 'users/:id/edit/:tab', :action => 'edit', :tab => nil
    end
    users.with_options :conditions => {:method => :post} do |user_actions|
      user_actions.connect 'users', :action => 'add'
      user_actions.connect 'users/new', :action => 'add'
      user_actions.connect 'users/:id/edit', :action => 'edit'
      user_actions.connect 'users/:id/memberships', :action => 'edit_membership'
      user_actions.connect 'users/:id/memberships/:membership_id', :action => 'edit_membership'
      user_actions.connect 'users/:id/memberships/:membership_id/destroy', :action => 'destroy_membership'
    end
  end
  
  map.with_options :controller => 'retros' do |retro_routes|
    retro_routes.with_options :conditions => {:method => :get} do |retro_views|
      retro_views.connect 'projects/:project_id/retros', :action => 'index'
      retro_views.connect 'projects/:project_id/retros/new', :action => 'new'
      retro_views.connect 'projects/:project_id/retros/:action', :action => /index_json/
      # retro_views.connect 'projects/:project_id/retros/:id', :action => 'show'
      retro_views.connect 'projects/:project_id/retros/:id/:action', :action => /show|dashdata/
      retro_views.connect 'projects/:project_id/retros/:id.:format', :action => 'show'
      retro_views.connect 'projects/:project_id/retros/:id/edit', :action => 'edit'
    end
    retro_routes.with_options :conditions => {:method => :post} do |retro_actions|
      retro_actions.connect 'projects/:project_id/retros', :action => 'new'
      retro_actions.connect 'projects/:project_id/retros/:id/:action', :action => /edit|destroy/
    end
  end
  
  
  map.with_options :controller => 'projects' do |projects|
    projects.with_options :conditions => {:method => :get} do |project_views|
      # project_views.connect 'issues/:show_issue_id.:format', :action => 'dashboard'
      project_views.connect 'projects', :action => 'index'
      project_views.connect 'projects.:format', :action => 'index'
      # project_views.connect 'projects/:action', :action => '/index|index_latest|index_active/'
      project_views.connect 'projects/new', :action => 'add'
      project_views.connect 'projects/index_latest', :action => 'index_latest'
      project_views.connect 'projects/index_active', :action => 'index_active'
      project_views.connect 'projects/update_scale', :action => 'update_scale'
      project_views.connect 'projects/:id', :action => 'overview'
      project_views.connect 'projects/:id/show', :action => 'overview'
      project_views.connect 'projects/:id/overview', :action => 'overview'
      project_views.connect 'projects/:id/:action', :action => /roadmap|changelog|destroy|settings|team|wiki|join_core_team|leave_core_team|core_vote|dashdata|new_dashdata|dashboard|mypris|agree|disagree|accept|reject|credits|shares|community_members|community_members_array|issue_search|hourly_types|map|join|overview|reset_invitation_code|overview/
      project_views.connect 'projects/:id/files', :action => 'list_files'
      project_views.connect 'projects/:id/files/new', :action => 'add_file'
      project_views.connect 'projects/:id/settings/:tab', :action => 'settings'
      project_views.connect 'issues/:show_issue_id', :action => 'dashboard'
    end

    projects.with_options :conditions => {:method => :post} do |project_actions|
      project_actions.connect 'projects/new', :action => 'add'
      project_actions.connect 'projects', :action => 'add'
      project_actions.connect 'projects/:id/:action', :action => /destroy|archive|unarchive|edit/
      project_actions.connect 'projects/:id/wiki', :action => 'wiki'
      project_actions.connect 'projects/:id/files/new', :action => 'add_file'
      project_actions.connect 'projects/:id/activities/save', :action => 'save_activities'
    end

    # projects.with_options :action => 'dashboard', :conditions => {:method => :get} do |dashboard|
    #   dashboard.connect 'projects/:id/dashboard'
    #   dashboard.connect 'projects/:id/dashboard.:format'
    # end
    
    projects.with_options :action => 'activity', :conditions => {:method => :get} do |activity|
      activity.connect 'projects/:id/activity'
      # activity.connect 'projects/:id/activity.:format'
      activity.connect 'activity', :id => nil
      # activity.connect 'activity.:format', :id => nil
    end
  end  
  
  map.with_options :controller => 'hourly_types' do |hourly_type_routes|
    hourly_type_routes.with_options :conditions => {:method => :get} do |hourly_type_views|
      hourly_type_views.connect 'projects/:project_id/hourly_types/new', :action => 'new'
      hourly_type_views.connect 'projects/:project_id/hourly_types/:id/edit', :action => 'edit'
    end
    hourly_type_routes.with_options :conditions => {:method => :post} do |hourly_type_action|
      hourly_type_action.connect 'projects/:project_id/hourly_types/new', :action => 'new'
      hourly_type_action.connect 'projects/:project_id/hourly_types/:id/:action', :action => /new|edit|destroy/
    end
  end
  
  map.with_options :controller => 'recurly_notifications' do |recurly_routes|
    recurly_routes.with_options :conditions => {:method => :post} do |recurly_action|
      recurly_action.connect 'recurly_notifications/listen', :action => 'listen'
    end
  end
  
  map.connect 'attachments/:id', :controller => 'attachments', :action => 'show', :id => /\d+/
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/

   
  map.resources :groups
  
  # map.your_activities '/feeds/your_activities/:activity_stream_token', :controller => 'activity_streams', :action => 'feed', :format => 'atom'
  # map.resources :activity_stream_preferences
  map.resources :activity_streams
  
  map.resources :projects, :has_many => :shares
  map.resources :projects, :has_many => :credits
  map.resources :projects, :has_many => :motions
  map.resources :projects, :has_many => :invitations
  
  
  #left old routes at the bottom for backwards compat
  map.connect 'projects/:project_id/issues/:action', :controller => 'issues'
  map.connect 'projects/:project_id/documents/:action', :controller => 'documents'
  map.connect 'projects/:project_id/boards/:action/:id', :controller => 'boards'
  map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'
  map.connect 'wiki/:id/:page/:action', :page => nil, :controller => 'wiki'
  map.connect 'issues/:issue_id/relations/:action/:id', :controller => 'issue_relations'
  map.connect 'projects/:project_id/news/:action', :controller => 'news'  
  map.connect 'projects/:project_id/motions/:action', :controller => 'motions'  
  map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/

  #semi-statig pages
  map.root :controller => 'home'
  map.home '', :controller => 'home', :action => 'index'
  map.static '/front/:page', :controller => 'home', :action => 'show', :page => /index.html|about.html|howitworks.html|contact.html|hq.html|pricing.html|signup.html|apps.html|products.html|services.html|single.html|tour.html|webdesign.html|index.htm|elements.html|privacy.html|library.html|testimonials.html|irb.html|open_enterprise_governance_model.html|user_agreement.html|why.html|how.html|what.html/                          
  
    
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect 'robots.txt', :controller => 'welcome', :action => 'robots'
  # Used for OpenID
  # map.root :controller => 'account', :action => 'login'
  
  map.resources :pages, :only => :show
      
  map.resources :todos
  map.resources :issue_votes

  map.resources :credits
  map.resources :shares
  map.resources :enterprises
  map.resources :comments
  map.resources :retro_ratings
  map.resources :retros
  map.resources :notifications
  map.resources :issues
  map.resources :credit_transfers
  
  # map.resources :motions
  
end
