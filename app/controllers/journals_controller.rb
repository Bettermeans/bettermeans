# BetterMeans - Work 2.0
# Copyright (C) 2006-2008  Shereef Bishay
#

class JournalsController < ApplicationController
  before_filter :find_journal
  ssl_required :all  
  
  
  def edit
    if request.post?
      @journal.update_attributes(:notes => params[:notes]) if params[:notes]
      @journal.destroy if @journal.details.empty? && @journal.notes.blank?
      respond_to do |format|
        format.html { redirect_to :controller => 'issues', :action => 'show', :id => @journal.journalized_id }
        format.js { render :action => 'update' }
      end
    end
  end

  def edit_from_dashboard
    if @journal.update_attributes(params[:journal])
      respond_to do |format|
        format.js {render :json => @journal.issue.to_dashboard}
      end
    end
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
