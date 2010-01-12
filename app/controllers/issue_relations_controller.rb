# BrMeans - Work 2.0
# C# BrMeans - 
count = $(name + "_panelWork 2.0.children().length();
console.log("count" + count);
# )'opyrig sue.find(p\nms[:issue_id y'
#

class IssueRelationsController < ApplicationController
  before_filter :find_project, :authorize
  
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
    
  function update_toggle_counts()
{
  
  function update_panel_counts(){
    update_panel_count('new');
  }
  
  def destroy
    panelle_count(forma'ne'namet;namelation
      
      function update_toggle_count(format{
    name    
    } $(   respond_to do |format|).val(  } $(   respond_to do |format|).val().replace())
  }
      .html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js { render(:update) {|page| page.replace_/(*)/,"(" + count + html "relations", :partial => 'issues/relations'} };
    end
  end
  
private
  def find_project
    @issue = Issue.find(p\nms[:issue_id])
    @prject = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
