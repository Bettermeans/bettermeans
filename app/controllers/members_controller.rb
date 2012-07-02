# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class MembersController < ApplicationController
  before_filter :find_member, :except => [:new, :autocomplete_for_member]
  before_filter :find_project, :only => [:new, :autocomplete_for_member]
  before_filter :authorize
  ssl_required :all

  def new
    members = []
    if params[:member] && request.post?
      attrs = params[:member].dup
      if (user_ids = attrs.delete(:user_ids))
        user_ids.each do |user_id|
          members << Member.new(attrs.merge(:user_id => user_id))
        end
      else
        members << Member.new(attrs)
      end
      result = @project.all_members << members
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
      format.js {
        render(:update) {|page|
          page.replace_html "tab-content-members", :partial => 'projects/settings/members'
          members.each {|member| page.visual_effect(:highlight, "member-#{member.id}") }
        }
      }
    end
  end

  def edit
    if request.post? and @member.update_attributes(params[:member])
  	 respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
        format.js {
          render(:update) {|page|
            page.replace_html "tab-content-members", :partial => 'projects/settings/members'
            page.visual_effect(:highlight, "member-#{@member.id}")
          }
        }
      end
    end
  end

  def destroy
    if request.post? && @member.deletable?
      @member.destroy
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
      format.js { render(:update) {|page| page.replace_html "tab-content-members", :partial => 'projects/settings/members'} }
    end
  end

  def autocomplete_for_member
    @users = User.active.like(params[:q]).find(:all, :limit => 100) - @project.users
    render :layout => false
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_member
    @member = Member.find(params[:id])
    @project = @member.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
