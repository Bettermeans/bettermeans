class TodosController < ApplicationController

  before_filter :find_issue, :only => [:index, :create, :update, :destroy ]
  before_filter :find_project, :authorize
  ssl_required :all


  # GET /todos
  # GET /todos.xml
  def index
    @todos = Todo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @todos }
    end
  end

  # GET /todos/1
  # GET /todos/1.xml
  def show
    @todo = Todo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @todo }
    end
  end

  # GET /todos/new
  # GET /todos/new.xml
  def new
    @todo = Todo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @todo }
    end
  end

  # GET /todos/1/edit
  def edit
    @todo = Todo.find(params[:id])
  end

  # POST /todos
  # POST /todos.xml
  def create
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

  # PUT /todos/1
  # PUT /todos/1.xml
  def update
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

  # DELETE /todos/1
  # DELETE /todos/1.xml
  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy

    respond_to do |format|
      format.js {render :json => @issue.to_dashboard}
      format.html { redirect_to(todos_url) }
      format.xml  { head :ok }
    end
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def find_project
    @project = @issue.project
  end

end
