class TodosController < ApplicationController

  before_filter :find_issue, :only => [:index, :create, :update, :destroy ]
  before_filter :find_project, :authorize
  ssl_required :all

  def index # spec_me cover_me heckle_me
    @todos = Todo.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @todos }
    end
  end

  def show # spec_me cover_me heckle_me
    @todo = Todo.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @todo }
    end
  end

  def new # spec_me cover_me heckle_me
    @todo = Todo.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @todo }
    end
  end

  def edit # spec_me cover_me heckle_me
    @todo = Todo.find(params[:id])
  end

  def create # spec_me cover_me heckle_me
    @todo = Todo.new(params[:todo])
    @todo.issue_id = @issue.id

    respond_to do |format|
      if @todo.save
        @issue.reload
        format.js {render :json => @issue.to_dashboard}
        format.html { redirect_to(@todo) }
        format.xml  { render :xml => @todo, :status => :created, :location => @todo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @todo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update # spec_me cover_me heckle_me
    @todo = Todo.find(params[:id])

    respond_to do |format|
      if @todo.update_attributes(params[:todo])
        @issue.reload
        format.js {render :json => @issue.to_dashboard}
        format.html { redirect_to(@todo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @todo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy # spec_me cover_me heckle_me
    @todo = Todo.find(params[:id])
    @todo.destroy

    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html { redirect_to(todos_url) }
      format.xml  { head :ok }
    end
  end

  private

  def find_issue # cover_me heckle_me
    @issue = Issue.find(params[:issue_id])
  end

  def find_project # cover_me heckle_me
    @project = @issue.project
  end

end
