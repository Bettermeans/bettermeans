# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

class JournalsController < ApplicationController
  before_filter :find_journal
  ssl_required :all  
  
  
  def edit
    if request.post?
      @journal.update_attributes(:notes => params[:notes]) if params[:notes]
      if @journal.details.empty? && @journal.notes.blank?
        @journal.destroy 
      else
        update_activity_stream(params[:notes]) if params[:notes]
      end
      
      respond_to do |format|
        format.html { redirect_to :controller => 'issues', :action => 'show', :id => @journal.journalized_id }
        format.js { render :action => 'update' }
      end
    end
  end

  def edit_from_dashboard
    if @journal.update_attributes(params[:journal])
      update_activity_stream(params[:journal][:notes])
      respond_to do |format|
        format.js {render :json => @journal.issue.to_dashboard}
      end
    end
  end
  
  def update_activity_stream(notes)
    ActivityStream.update_all("indirect_object_description = '#{notes}'", {:indirect_object_id => @journal.id, :indirect_object_type => "Journal", :object_type => "Issue", :actor_id => User.current.id}, :order => 'created_at DESC', :limit => 1)
  end
  
private
  def find_journal
    @journal = Journal.find(params[:id])
    (render_403; return false) unless @journal.editable_by?(User.current)
    @project = @journal.journalized.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
