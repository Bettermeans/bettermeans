# Redmine - project management software
# Copyright (C) 2006-2011  See readme for details and license
#


class IssueRelationsController < ApplicationController
  before_filter :find_project, :authorize
  ssl_required :all

  def new
    @relation = IssueRelation.new(params[:relation])
    @relation.issue_from = @issue
    if params[:relation] && !params[:relation][:issue_to_id].blank?
      @relation.issue_to = Issue.visible.find_by_id(params[:relation][:issue_to_id])
    end
    @relation.save if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js do
        render :update do |page|
          page.replace_html "relations", :partial => 'issues/relations'
          if @relation.errors.empty?
            page << "$('relation_delay').value = ''"
            page << "$('relation_issue_to_id').value = ''"
          end
        end
      end
    end
  end

  def destroy
    relation = IssueRelation.find(params[:id])
    if request.post? && @issue.relations.include?(relation)
      relation.destroy
      @issue.reload
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js { render(:update) {|page| page.replace_html "relations", :partial => 'issues/relations'} }
    end
  end

  private

  def find_project
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
