# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module ProjectsHelper
  def project_settings_tabs
    tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
            {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
            {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
            {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
            {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural},
            {:name => 'hourly_types', :action => :manage_boards, :partial => 'projects/settings/hourly_types', :label => :label_hourly_type_plural}
            ]
    tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}     
  end
  
  def team_action_links(project)
    content = ''
    
    #Link to join core if user is a core member of the parent workstream and isn't already on core, or if user has enough points
    content << link_to_remote(l(:label_join_core_team), {:url => {:controller => 'projects', :action => 'join_core_team', :id => project}, :method => :post}, 
                                           :class => 'icon icon-add') << '  ' if  @project.eligible_for_core?(User.current) unless User.current.core_member_of?(@project)
    
    #Link to request joining core if user is a contributor and isn't a core member of the parent workstream
    # content << link_to_remote(l(:label_request_to_join_core_team), {:url => {:controller => 'team_offers', :action => 'add', :project => project, :author => User.current}, :method => :post}, 
    #                                             :class => 'icon icon-cr-request') << '  ' if  !@project.eligible_for_core?(User.current) && User.current.contributor_of?(@project)
    
    #Link to leave core if user is on core
    content << link_to_remote(l(:label_leave_core_team), {:url => {:controller => 'projects', :action => 'leave_core_team', :id => project}, :method => :post}, 
                                           :class => 'icon icon-cr-decline') << '  ' if  User.current.core_member_of?(@project)
                                           
    #Link to invite users to core, if user is on core
    # content << link_to_remote(l(:label_invitation_to_join_core_team), {:url => {:controller => 'team_offers', :action => 'add', :project => project, :author => User.current}, :method => :post}, 
    #                                             :class => 'icon icon-cr-offer') << '  ' if  User.current.core_member_of?(@project)
  
    #Help link: How do I join this team? if user is not a contributor, telling them to become a contributor first
    content << help_link(:how_do_i_join_a_team,:show_name => :true) unless User.current.member_of?(@project)
    
    content

  end

  def nomination_links(member,project)
    return if member.user_id == User.current.id
    return unless User.current.binding_voter_of?(project)
    content = ''
    
    #Link to nominate to core if user is a member
    content << link_to(l(:label_nominate_to_core_team), project_motions_path(project, "motion[variation]" => Motion::VARIATION_NEW_CORE, "motion[concerned_user_id]" => member.user_id), 
                                           :class => 'icon icon-cr-offer',
                                           :method => :post) << '&nbsp;&nbsp;&nbsp;&nbsp;' if member.roles.first.id  == Role::BUILTIN_MEMBER
    
    #Link to drop from core if user is a core member
    content << link_to(l(:label_drop_from_core_team), project_motions_path(project, "motion[variation]" => Motion::VARIATION_FIRE_CORE, "motion[concerned_user_id]" => member.user_id), 
                                          :method => :post,
                                           :class => 'icon icon-cr-decline') << '  ' if member.roles.first.id  == Role::BUILTIN_CORE_MEMBER


    #Link to nominate to member if user is contributor, and current user is a binding member
    content << link_to(l(:label_nominate_to_member), project_motions_path(project, "motion[variation]" => Motion::VARIATION_NEW_MEMBER, "motion[concerned_user_id]" => member.user_id), 
                                          :method => :post,
                                           :class => 'icon icon-cr-offer') << '  ' if member.roles.first.id  == Role::BUILTIN_CONTRIBUTOR
    
    #Link to drop from member if user is member, and current user is binding member
    content << link_to(l(:label_drop_from_member), project_motions_path(project, "motion[variation]" => Motion::VARIATION_FIRE_MEMBER, "motion[concerned_user_id]" => member.user_id), 
                                          :method => :post,
                                           :class => 'icon icon-cr-decline') << '  ' if member.roles.first.id  == Role::BUILTIN_MEMBER
    content
  end
  
  def parent_project_select_tag(project)
    selected = project.parent
    # retrieve the requested parent project
    parent_id = (params[:project] && params[:project][:parent_id]) || params[:parent_id]
    if parent_id
      selected = (parent_id.blank? ? nil : Project.find(parent_id))
    end
    
    options = ''
    options << "<option value=''></option>" if project.allowed_parents.include?(nil)
    options << project_tree_options_for_select(project.allowed_parents.compact, :selected => selected)
    content_tag('select', options, :name => 'project[parent_id]')
  end  
  
  # Renders a tree of projects as a nested set of unordered lists
  # The given collection may be a subset of the whole project tree
  # (eg. some intermediate nodes are private and can not be seen)
  def render_project_hierarchy(projects)
    s = ''
    if projects.any?
      ancestors = []
      projects.each do |project|
        if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
          s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
        else
          ancestors.pop
          s << "</li>"
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
            ancestors.pop
            s << "</ul></li>\n"
          end
        end
        classes = (ancestors.empty? ? 'root' : 'child')
        s << "<li class='#{classes}'><div class='#{classes}'>" +
               link_to(h(project), {:controller => 'projects', :action => 'show', :id => project}, :class => "project #{User.current.member_of?(project) ? 'my-project' : nil}")
        s << "<div class='wiki description'>#{textilizable(project.short_description, :project => project)}</div>" unless project.description.blank?
        s << "</div>\n"
        ancestors << project
      end
      s << ("</li></ul>\n" * ancestors.size)
    end
    s
  end
  
end
