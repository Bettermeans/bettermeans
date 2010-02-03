class RetrosController < ApplicationController
  before_filter :find_project, :authorize

  # GET /retros
  # GET /retros.xml
  def index
    @retros = Retro.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @retros }
    end
  end
  
  def index_json
    # render :json => Retro.find(:all, :conditions => {:project_id => @project.id}).to_json
    render :json => Retro.all.to_json
  end
  
  def dashdata
    render :json => Issue.find(:all, :conditions => {:retro_id => params[:id]}).to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
  end
  

  # GET /retros/1
  # GET /retros/1.xml
  def show
    @retro = Retro.find(params[:id])
    @user_retro_hash = {}
    new_user_retro = {"issues" => [], "total_points" => 0, "percentage_points" => 0, "journals" => [], "total_journals" => 0, "votes" => [], "total_votes" => 0}
    
    # @issue_group = Issue.find(:all,:include => :assigned_to, :conditions => {:retro_id => @retro.id}).group_by{|issue| issue.assigned_to_id}
    issue_group = @retro.issues.group_by{|issue| issue.assigned_to_id}
    
    #Calculating oustanding points for entire retrospective
    @total_points = 0
    issue_group.each_value {|issues| @total_points += issues.collect(&:points).sum }
    
    #Adding users that have issues assigned to them and calculating total points for each user
    issue_group.keys.sort.each do |assigned_to_id|
      @user_retro_hash.store assigned_to_id, new_user_retro.dup unless @user_retro_hash.has_key? assigned_to_id
      @user_retro_hash[assigned_to_id].store "issues", issue_group[assigned_to_id]
      @user_retro_hash[assigned_to_id].store "total_points", issue_group[assigned_to_id].collect(&:points).sum 
      @user_retro_hash[assigned_to_id].store "percentage_points", (@user_retro_hash[assigned_to_id]["total_points"] / @total_points * 100).round_to(1)
    end
    
    #Total journals
    journals_group = @retro.journals.group_by{|journal| journal.user_id}
    journals_group.keys.sort.each do |user_id|
      @user_retro_hash.store user_id, new_user_retro.dup unless @user_retro_hash.has_key? user_id
      @user_retro_hash[user_id].store "journals", journals_group[user_id]
      @user_retro_hash[user_id].store "total_journals", journals_group[user_id].length
    end
    
    
    #Total voting activity
    votes_group = @retro.issue_votes.group_by{|issue_vote| issue_vote.user_id}
    votes_group.keys.sort.each do |user_id|
      @user_retro_hash.store user_id, new_user_retro.dup unless @user_retro_hash.has_key? user_id
      @user_retro_hash[user_id].store "votes", votes_group[user_id]
      @user_retro_hash[user_id].store "total_votes", votes_group[user_id].length
    end

    #Average time taken to complete a point?
        

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retro }
    end
  end

  # GET /retros/new
  # GET /retros/new.xml
  def new
    @retro = Retro.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retro }
    end
  end

  # GET /retros/1/edit
  def edit
    @retro = Retro.find(params[:id])
  end

  # POST /retros
  # POST /retros.xml
  def create
    @retro = Retro.new(params[:retro])

    respond_to do |format|
      if @retro.save
        flash[:notice] = 'Retro was successfully created.'
        format.html { redirect_to(@retro) }
        format.xml  { render :xml => @retro, :status => :created, :location => @retro }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retros/1
  # PUT /retros/1.xml
  def update
    @retro = Retro.find(params[:id])

    respond_to do |format|
      if @retro.update_attributes(params[:retro])
        flash[:notice] = 'Retro was successfully updated.'
        format.html { redirect_to(@retro) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retro.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retros/1
  # DELETE /retros/1.xml
  def destroy
    @retro = Retro.find(params[:id])
    @retro.destroy

    respond_to do |format|
      format.html { redirect_to(retros_url) }
      format.xml  { head :ok }
    end
  end
  
  def find_project
    @project = Project.find(params[:project_id])
  end
end
