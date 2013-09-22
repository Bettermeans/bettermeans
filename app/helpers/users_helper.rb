# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module UsersHelper
  def users_status_options_for_select(selected) # spec_me cover_me heckle_me
    user_count_by_status = User.count(:group => 'status').to_hash
    options_for_select([[l(:label_all), ''],
                        ["#{l(:status_active)} (#{user_count_by_status[1].to_i})", 1],
                        ["#{l(:status_registered)} (#{user_count_by_status[2].to_i})", 2],
                        ["#{l(:status_locked)} (#{user_count_by_status[3].to_i})", 3]], selected)
  end

  # Options for the new membership projects combo-box
  def options_for_membership_project_select(user, projects) # spec_me cover_me heckle_me
    options = content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---")
    options << project_tree_options_for_select(projects) do |p|
      {:disabled => (user.projects.include?(p))}
    end
    options
  end

  def change_status_link(user) # spec_me cover_me heckle_me
    url = {:controller => 'users', :action => 'edit', :id => user, :page => params[:page], :status => params[:status], :tab => nil}

    if user.locked?
      link_to l(:button_unlock), url.merge(:user => {:status => User::STATUS_ACTIVE}), :method => :post, :class => 'icon icon-unlock'
    elsif user.registered?
      link_to l(:button_activate), url.merge(:user => {:status => User::STATUS_ACTIVE}), :method => :post, :class => 'icon icon-unlock'
    elsif user != User.current
      link_to l(:button_lock), url.merge(:user => {:status => User::STATUS_LOCKED}), :method => :post, :class => 'icon icon-lock'
    end
  end

  def user_settings_tabs # spec_me cover_me heckle_me
    tabs = [{:name => 'general', :partial => 'users/general', :label => :label_general},
            {:name => 'memberships', :partial => 'users/memberships', :label => :label_project_plural}
            ]
    tabs
  end


  def reputation_value(reputation_type, reputation_value) # spec_me cover_me heckle_me
    case reputation_type
    when Reputation::VARIATION_SELF_BIAS
      tame_bias(reputation_value)
    when Reputation::VARIATION_SCALE_BIAS
      tame_scale(reputation_value)
    end
  end

  def reputation_project(reputation) # spec_me cover_me heckle_me
    if reputation.project_id != 0
      link_to(h(reputation.project.name_with_ancestors), :controller => 'projects', :action => 'show', :id => reputation.project)
    else
      "Platform Wide"
    end
  end
end
