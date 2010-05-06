# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module ProjectsHelper
  def link_to_version(version, options = {})
    return '' unless version && version.is_a?(Version)
    link_to_if version.visible?, format_version_name(version), { :controller => 'versions', :action => 'show', :id => version }, options
  end
  
  def project_settings_tabs
    tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
            {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
            {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
            {:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural},
            {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
            {:name => 'repository', :action => :manage_repository, :partial => 'projects/settings/repository', :label => :label_repository},
            {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural},
            {:name => 'activities', :action => :manage_project_activities, :partial => 'projects/settings/activities', :label => :enumeration_activities}
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

  # Returns a set of options for a select field, grouped by project.
  def version_options_for_select(versions, selected=nil)
    grouped = Hash.new {|h,k| h[k] = []}
    versions.each do |version|
      grouped[version.project.name] << [version.name, version.id]
    end
    # Add in the selected
    if selected && !versions.include?(selected)
      grouped[selected.project.name] << [selected.name, selected.id]
    end
    
    if grouped.keys.size > 1
      grouped_options_for_select(grouped, selected && selected.id)
    else
      options_for_select((grouped.values.first || []), selected && selected.id)
    end
  end

  def format_version_sharing(sharing)
    sharing = 'none' unless Version::VERSION_SHARINGS.include?(sharing)
    l("label_version_sharing_#{sharing}")
  end
end
