# BetterMeans - Work 2.0
# Copyright (C) 2006  Shereef Bishay
#

module ProjectsHelper
  def project_settings_tabs
    tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
            {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
            {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
            # {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
            # {:name => 'hourly_types', :action => :manage_boards, :partial => 'projects/settings/hourly_types', :label => :label_hourly_type_plural},
            {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural}
            ]
    tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}     
  end
  
  def project_image(project)
  begin
    content_tag('div', (image_tag formatted_project_path(@project, :png)), :class => "gt-sidebar-logo") if project && project.has_image?
  rescue
  end
  end
  
  def nomination_links(member,project)
    return if member.user_id == User.current.id
    return unless User.current.binding_voter_of?(project)
    content = '<p class="gt-table-action-list">'
    
    #Link to nominate to core if user is a member
    content << link_to(l(:label_nominate_to_core_team), project_motions_path(project, "motion[variation]" => Motion::VARIATION_NEW_CORE, "motion[concerned_user_id]" => member.user_id), 
                                           :class => 'icon icon-cr-offer',
                                           :confirm => "Are you sure you want to start a motion to nominate #{member.name} to the Core Team?",
                                           :method => :post) << '&nbsp;&nbsp;&nbsp;&nbsp;' if member.roles.first.id  == Role::BUILTIN_MEMBER
                                           
    
    #Link to drop from core if user is a core member
    content << link_to(l(:label_drop_from_core_team), project_motions_path(project, "motion[variation]" => Motion::VARIATION_FIRE_CORE, "motion[concerned_user_id]" => member.user_id), 
                                          :method => :post,
                                          :confirm => "Are you sure you want to start a motion to remove #{member.name} from the Core Team and make her a Member?",
                                           :class => 'icon icon-cr-decline') << '  ' if member.roles.first.id  == Role::BUILTIN_CORE_MEMBER


    #Link to nominate to member if user is contributor, and current user is a binding member
    content << link_to(l(:label_nominate_to_member), project_motions_path(project, "motion[variation]" => Motion::VARIATION_NEW_MEMBER, "motion[concerned_user_id]" => member.user_id), 
                                          :method => :post,
                                          :confirm => "Are you sure you want to start a motion to nominate #{member.name} as a Member?",
                                           :class => 'icon icon-cr-offer') << '  ' if member.roles.first.id  == Role::BUILTIN_CONTRIBUTOR
    
    #Link to drop from member if user is member, and current user is binding member
    content << link_to(l(:label_drop_from_member), project_motions_path(project, "motion[variation]" => Motion::VARIATION_FIRE_MEMBER, "motion[concerned_user_id]" => member.user_id), 
                                          :confirm => "Are you sure you want to start a motion to remove the membership of #{member.name}",
                                          :method => :post,
                                           :class => 'icon icon-cr-decline') << '  ' if member.roles.first.id  == Role::BUILTIN_MEMBER
 
    content << "</p"
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
