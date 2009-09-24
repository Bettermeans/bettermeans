# This example controller assumes you are using the User class from restful_authentication
# and a nested voteable resource. See routes.rb


class VoteablesController < ApplicationController

  before_filter :find_user
  before_filter :login_required, :only => [:new, :edit, :destroy, :create, :update]
  before_filter :must_own_voteable, :only => [:edit, :destroy, :update]

  # GET /users/:id/voteables
  # GET /users/:id/voteables.xml
  def index
    @voteable = Voteable.descending

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @voteables }
    end
  end

  # GET /users/:id/voteables/1
  # GET /users/:id/voteables/1.xml
  def show
    @voteable = Voteable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voteable }
    end
  end

  # GET /users/:id/voteables/new
  # GET /users/:id/voteables/new.xml
  def new
    @voteable = Voteable.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voteable }
    end
  end

  # GET /users/:id/voteables/1/edit
  def edit 
    @voteable ||= Voteable.find(params[:id])
  end

  # POST /users/:id/voteables
  # POST /users/:id/voteables.xml
  def create
    @voteable = Voteable.new(params[:voteable])
    @voteable.user = current_user
    
    respond_to do |format|
      if @voteable.save
        flash[:notice] = 'Voteable was successfully saved.'
        format.html { redirect_to([@user, @voteable]) }
        format.xml  { render :xml => @voteable, :status => :created, :location => @voteable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voteable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/:id/voteable/1
  # PUT /users/:id/voteable/1.xml
  def update
    @voteable = Voteable.find(params[:id])
    
    respond_to do |format|
      if @quote.update_attributes(params[:voteable])
        flash[:notice] = 'Voteable was successfully updated.'
        format.html { redirect_to([@user, @voteable]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voteable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/:id/voteable/1
  # DELETE /users/:id/voteable/1.xml
  def destroy
    @voteable = Voteable.find(params[:id])
    @voteable.destroy

    respond_to do |format|
      format.html { redirect_to(user_voteables_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def find_user 
    @user = User.find(params[:user_id])
  end
    
  def must_own_voteable
    @voteable ||= Voteable.find(params[:id])
    @voteable.user == current_user || ownership_violation
  end
  
  def ownership_violation
    respond_to do |format|
      flash[:notice] = 'You cannot edit or delete voteable that you do not own!'
      format.html do
        redirect_to user_path(current_user)
      end
    end
  end
  
  
  
end
