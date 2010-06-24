ActionController::Routing::Routes.draw do |map|

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

  map.home '', :controller => 'welcome'
  
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  
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
      time_details.connect 'time_entries.:format'
      time_details.connect 'issues/:issue_id/time_entries'
      time_details.connect 'issues/:issue_id/time_entries.:format'
      time_details.connect 'projects/:project_id/time_entries.:format'
      time_details.connect 'projects/:project_id/issues/:issue_id/time_entries'
      time_details.connect 'projects/:project_id/issues/:issue_id/time_entries.:format'
    end
    timelog.connect 'projects/:project_id/time_entries/report', :action => 'report'
    timelog.with_options :action => 'report',:conditions => {:method => :get} do |time_report|
      time_report.connect 'time_entries/report'
      time_report.connect 'time_entries/report.:format'
      time_report.connect 'projects/:project_id/time_entries/report.:format'
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
  
  map.with_options :controller => 'boards' do |board_routes|
    board_routes.with_options :conditions => {:method => :get} do |board_views|
      board_views.connect 'projects/:project_id/boards', :action => 'index'
      board_views.connect 'projects/:project_id/boards/new', :action => 'new'
      board_views.connect 'projects/:project_id/boards/:id', :action => 'show'
      board_views.connect 'projects/:project_id/boards/:id.:format', :action => 'show'
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
      # issues_views.connect 'issues/:id/dashdata', :action => 'dashdata'
      issues_views.connect 'issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues', :action => 'index'
      issues_views.connect 'projects/:project_id/issues.:format', :action => 'index'
      issues_views.connect 'projects/:project_id/issues/new', :action => 'new'
      issues_views.connect 'projects/:project_id/issues/gantt', :action => 'gantt'
      issues_views.connect 'projects/:project_id/issues/calendar', :action => 'calendar'
      issues_views.connect 'projects/:project_id/issues/:copy_from/copy', :action => 'new'
      # issues_views.connect 'issues/:id', :controller => :action => 'show', :id => /\d+/
      # issues_views.connect 'issues/:id.:format', :action => 'show', :id => /\d+/
      issues_views.connect 'issues/:id/edit', :action => 'edit', :id => /\d+/
      issues_views.connect 'issues/:id/move', :action => 'move', :id => /\d+/
      issues_views.connect 'issues/:id/show', :action => 'show', :id => /\d+/
    end
    issues_routes.with_options :conditions => {:method => :post} do |issues_actions|
      issues_actions.connect 'projects/:project_id/issues', :action => 'new'
      issues_actions.connect 'issues/:id/quoted', :action => 'reply', :id => /\d+/
      issues_actions.connect 'issues/:id/:action', :action => /edit|move|destroy|start|finish|release|cancel|restart|prioritize|agree|disagree|estimate|accept|reject|join|leave|add_team_member/, :id => /\d+/
    end
    # issues_routes.connect 'issues/:action'
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
      project_views.connect 'issues/:show_issue_id', :action => 'projects/dashboard'
      project_views.connect 'issues/:show_issue_id.:format', :action => 'projects/dashboard'
      project_views.connect 'projects', :action => 'index'
      project_views.connect 'projects.:format', :action => 'index'
      project_views.connect 'projects/new', :action => 'add'
      project_views.connect 'projects/update_scale', :action => 'update_scale'
      project_views.connect 'projects/:id', :action => 'show'
      project_views.connect 'projects/:id/:action', :action => /roadmap|changelog|destroy|settings|team|wiki|join_core_team|leave_core_team|core_vote|dashdata|new_dashdata|dashboard|mypris|agree|disagree|accept|reject|credits|shares|community_members|hourly_types/
      project_views.connect 'projects/:id/files', :action => 'list_files'
      project_views.connect 'projects/:id/files/new', :action => 'add_file'
      project_views.connect 'projects/:id/settings/:tab', :action => 'settings'
    end

    projects.with_options :conditions => {:method => :post} do |project_actions|
      project_actions.connect 'projects/new', :action => 'add'
      project_actions.connect 'projects', :action => 'add'
      project_actions.connect 'projects/:id/:action', :action => /destroy|archive|unarchive|edit/
      project_actions.connect 'projects/:id/wiki', :action => 'wiki'
      project_actions.connect 'projects/:id/files/new', :action => 'add_file'
      project_actions.connect 'projects/:id/activities/save', :action => 'save_activities'
    end

    projects.with_options :action => 'dashboard', :conditions => {:method => :get} do |dashboard|
      dashboard.connect 'projects/:id/dashboard'
      dashboard.connect 'projects/:id/dashboard.:format'
    end
    
    projects.with_options :action => 'activity', :conditions => {:method => :get} do |activity|
      activity.connect 'projects/:id/activity'
      activity.connect 'projects/:id/activity.:format'
      activity.connect 'activity', :id => nil
      activity.connect 'activity.:format', :id => nil
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
  
  map.connect 'attachments/:id', :controller => 'attachments', :action => 'show', :id => /\d+/
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/
   
  map.resources :groups
  
  map.resources :projects, :has_many => :shares
  map.resources :projects, :has_many => :credits
  map.resources :projects, :has_many => :motions
  
  
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
  
  
  # Vote fu mappings
  map.resources :users do |user|
    user.resources :commit_requests
    user.resources :votes
    user.resources :journal do |mv|
      mv.resources :votes    
    end
    user.resources :message do |mv|
      mv.resources :votes    
    end
    user.resources :reply do |mv|
      mv.resources :votes    
    end
    user.resources :issue do |mv|
      mv.resources :votes
    end
  end
    
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect 'robots.txt', :controller => 'welcome', :action => 'robots'
  # Used for OpenID
  map.root :controller => 'account', :action => 'login'
  
      
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
  # map.resources :motions
  
end
