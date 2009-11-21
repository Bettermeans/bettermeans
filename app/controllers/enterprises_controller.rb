class EnterprisesController < ApplicationController
  # GET /enterprises
  # GET /enterprises.xml
  def index
    @enterprises = Enterprise.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @enterprises }
    end
  end

  # GET /enterprises/1
  # GET /enterprises/1.xml
  def show
    @enterprise = Enterprise.find(params[:id])
    
    # if params[:jump]
    #   # try to redirect to the requested menu item
    #   redirect_to_project_menu_item(@project, params[:jump]) && return
    # end
    
    # @users_by_role = @project.users_by_role
    # @subprojects = @project.children.visible
    # @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    # @trackers = @project.rolled_up_trackers
    # 
    # cond = @project.project_condition(Setting.display_subprojects_issues?)
    # 
    # @open_issues_by_tracker = Issue.visible.count(:group => :tracker,
    #                                         :include => [:project, :status, :tracker],
    #                                         :conditions => ["(#{cond}) AND #{IssueStatus.table_name}.is_closed=?", false])
    # @total_issues_by_tracker = Issue.visible.count(:group => :tracker,
    #                                         :include => [:project, :status, :tracker],
    #                                         :conditions => cond)
    # 
    # TimeEntry.visible_by(User.current) do
    #   @total_hours = TimeEntry.sum(:hours, 
    #                                :include => :project,
    #                                :conditions => cond).to_f
    # end
    # @key = User.current.rss_key

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enterprise }
    end
  end

  # GET /enterprises/new
  # GET /enterprises/new.xml
  def new
    @enterprise = Enterprise.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @enterprise }
    end
  end

  # GET /enterprises/1/edit
  def edit
    @enterprise = Enterprise.find(params[:id])
  end

  # POST /enterprises
  # POST /enterprises.xml
  def create
    @enterprise = Enterprise.new(params[:enterprise])

    respond_to do |format|
      if @enterprise.save
        flash[:notice] = 'Enterprise was successfully created.'
        format.html { redirect_to(@enterprise) }
        format.xml  { render :xml => @enterprise, :status => :created, :location => @enterprise }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @enterprise.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /enterprises/1
  # PUT /enterprises/1.xml
  def update
    @enterprise = Enterprise.find(params[:id])

    respond_to do |format|
      if @enterprise.update_attributes(params[:enterprise])
        flash[:notice] = 'Enterprise was successfully updated.'
        format.html { redirect_to(@enterprise) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enterprise.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /enterprises/1
  # DELETE /enterprises/1.xml
  def destroy
    @enterprise = Enterprise.find(params[:id])
    @enterprise.destroy

    respond_to do |format|
      format.html { redirect_to(enterprises_url) }
      format.xml  { head :ok }
    end
  end
end
