class RetrosController < ApplicationController
  before_filter :find_retro, :only => [:show]
  before_filter :find_project, :only => [:index, :index_json, :dashdata, :new, :edit, :create, :update, :destroy, :show_multiple]
  before_filter :authorize
  ssl_required :all


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
    render :json => Retro.find(:all, :conditions => {:project_id => @project.id}).to_json
    # render :json => Retro.all.to_json
  end

  def dashdata
    render :json => Issue.find(:all, :conditions => {:retro_id => params[:id]}).to_json(:include => {:journals => {:include => :user}, :issue_votes => {:include => :user}, :status => {:only => :name}, :todos => {:only => [:id, :subject, :completed_on]}, :tracker => {:only => [:name,:id]}, :author => {:only => [:firstname, :lastname, :login]}, :assigned_to => {:only => [:firstname, :lastname, :login]}})
  end

  def show

    @retro = Retro.find(params[:id])
    @team_hash = {}
    @final_hash = {}
    @user_retro_hash = {}

    new_user_retro = {"issues" => [],
                    "total_points" => 0,
                    "percentage_points" => 0,
                    "given_percentage" => 0,
                    "self_bias" => nil,
                    "scale_bias" => nil,
                    "journals" => [],
                    "total_journals" => 0,
                    "votes" => [],
                    "total_votes" => 0,
                    "total_ideas" => 0
                    }

    #Calculating oustanding points for entire retrospective
    @total_points = 0
    @total_ideas = @retro.issues.length

    @max_range = 0
    @pie_data_points = []
    @pie_labels_points = []
    @max_points = 0

    #Calculating team size for issues (to distribute total points amongst team)
    issue_team_sizes = Hash.new
    @retro.issues.each {|issue| issue_team_sizes[issue.id] = 1}

    @retro.issues.each do |issue|
      issue.issue_votes.each do |issue_vote|
          next if issue_vote.vote_type != IssueVote::JOIN_VOTE_TYPE
          #Incrementing team size for the issue
          issue_team_sizes[issue_vote.issue_id] += 1 if issue_vote.user_id != issue.assigned_to_id
      end
    end

    #Adding users that have issues assigned to them and calculating total points for each user
    issue_group = @retro.issues.group_by{|issue| issue.assigned_to_id}
    issue_group.each_value {|issues| @total_points += issues.collect(&:points).sum }
    issue_group.keys.sort.each do |assigned_to_id|
      next if (@user_retro_hash.has_key? assigned_to_id)  || assigned_to_id == User.sysadmin.id
      @user_retro_hash.store assigned_to_id, new_user_retro.dup
      @user_retro_hash[assigned_to_id].store "issues", issue_group[assigned_to_id]
      @user_retro_hash[assigned_to_id].store "total_points", 0
    end

    #Adding users that have joined the issues and calculating total points for each user
    @retro.issues.each do |issue|
      points = issue.points.to_f / (issue_team_sizes[issue.id])
      next if issue.assigned_to_id == User.sysadmin.id
      @user_retro_hash[issue.assigned_to_id]["total_points"]+=points
      @max_points = @user_retro_hash[issue.assigned_to_id]["total_points"] if @user_retro_hash[issue.assigned_to_id]["total_points"] > @max_points

      issue.issue_votes.each do |issue_vote|
        next if issue_vote.vote_type != IssueVote::JOIN_VOTE_TYPE || issue_vote.user_id == User.sysadmin.id
        if @user_retro_hash.has_key? issue_vote.user_id
          @user_retro_hash[issue_vote.user_id]["total_points"]+=points if issue_vote.user_id != issue.assigned_to_id
        else
          @user_retro_hash.store issue_vote.user_id, new_user_retro.dup
          @user_retro_hash[issue_vote.user_id].store "issues", []
          @user_retro_hash[issue_vote.user_id].store "total_points", points
        end
        @max_points = @user_retro_hash[issue_vote.user_id]["total_points"] if @user_retro_hash[issue_vote.user_id]["total_points"] > @max_points

      end
    end

    @user_retro_hash.delete(nil)

    @user_retro_hash.keys.each do |key|
      @user_retro_hash[key].store "percentage_points", @total_points == 0 ? 100  : (@user_retro_hash[key]["total_points"].to_f / @total_points * 100).round_to(0).to_i
      @pie_data_points << @user_retro_hash[key]["percentage_points"]
      @pie_labels_points << User.find(key).firstname + " #{@user_retro_hash[key]["percentage_points"].to_s}%"
    end


    @max_ideas = 0

    #Adding users that have authored issues and calculating total ideas generated per user
    author_group = @retro.issues.group_by{|issue| issue.author_id}
    author_group.keys.sort.each do |author_id|
      next if author_id == User.sysadmin.id
      if !(@user_retro_hash.has_key? author_id)
        @user_retro_hash.store author_id, new_user_retro.dup
        @user_retro_hash[author_id].store "issues", []
        @user_retro_hash[author_id].store "total_points", 0
        @user_retro_hash[author_id].store "percentage_points", 0
      end
      @user_retro_hash[author_id].store "total_ideas", author_group[author_id].length
      @max_ideas = @user_retro_hash[author_id]["total_ideas"] if @user_retro_hash[author_id]["total_ideas"] > @max_ideas
    end

    @max_range = @max_ideas if @max_ideas > @max_range

    #Adding users that have authored journals
    @retro.journals.each do |journal|
      next if (@user_retro_hash.has_key? journal.user_id) || journal.user_id == User.sysadmin.id
      @user_retro_hash.store journal.user_id, new_user_retro.dup
      @user_retro_hash[journal.user_id].store "issues", []
      @user_retro_hash[journal.user_id].store "total_points", 0
      @user_retro_hash[journal.user_id].store "percentage_points", 0
    end

    @confidence_percentage = 100
    @retro.retro_ratings.each do |retro_rating|
      next if retro_rating.ratee_id == User.sysadmin.id || retro_rating.rater_id == User.sysadmin.id
      @user_retro_hash.store retro_rating.ratee_id, new_user_retro.dup unless @user_retro_hash.has_key? retro_rating.ratee_id
      @user_retro_hash[retro_rating.ratee_id].store "given_percentage", retro_rating.score.round if retro_rating.rater_id == User.current.id
      @confidence_percentage = retro_rating.confidence if retro_rating.rater_id == User.current.id
      @team_hash[retro_rating.ratee_id] = retro_rating.score.round if retro_rating.rater_id == RetroRating::TEAM_AVERAGE
      @final_hash[retro_rating.ratee_id] = retro_rating.score.round_to(0) if retro_rating.rater_id == RetroRating::FINAL_AVERAGE
      @user_retro_hash[retro_rating.ratee_id].store "self_bias", retro_rating.score.round if retro_rating.rater_id == RetroRating::SELF_BIAS
      @user_retro_hash[retro_rating.ratee_id].store "scale_bias", retro_rating.score.round if retro_rating.rater_id == RetroRating::SCALE_BIAS
    end

    # @retro.retro_ratings.each do |retro_rating|
    #   next if  retro_rating.rater_id == RetroRating::TEAM_AVERAGE ||  retro_rating.rater_id == RetroRating::FINAL_AVERAGE
    #   @delta_hash_self[retro_rating.rater_id] ||= 0
    #   @delta_hash_other[retro_rating.rater_id] ||= 0
    #   @bias_self[retro_rating.rater_id] ||= 0
    #   if (retro_rating.ratee_id == retro_rating.rater_id)
    #     @delta_hash_self[retro_rating.rater_id] += (retro_rating.score - @final_hash[retro_rating.rater_id]).abs
    #     @bias_self[retro_rating.rater_id] = ((@final_hash[retro_rating.rater_id] - retro_rating.score) / @final_hash[retro_rating.rater_id]) * -100
    #   else
    #     @delta_hash_other[retro_rating.rater_id] += (retro_rating.score - @final_hash[retro_rating.ratee_id]).abs
    #   end
    # end unless @final_hash.count == 0

    #Total journals
    @total_journals = @retro.journals.length
    @pie_data_journals = []
    @pie_labels_journals = []
    @max_journals = 0
    journals_group = @retro.journals.group_by{|journal| journal.user_id}
    journals_group.keys.sort.each do |user_id|
      next if user_id == User.sysadmin.id
      @user_retro_hash.store user_id, new_user_retro.dup unless @user_retro_hash.has_key? user_id
      @user_retro_hash[user_id].store "journals", journals_group[user_id]
      @user_retro_hash[user_id].store "total_journals", journals_group[user_id].length
      @user_retro_hash[user_id].store "percentage_journals", (@user_retro_hash[user_id]["total_journals"].to_f / @total_journals * 100).round_to(0).to_i
      @max_journals = @user_retro_hash[user_id]["total_journals"] if @user_retro_hash[user_id]["total_journals"] > @max_journals
      @pie_data_journals << @user_retro_hash[user_id]["percentage_journals"]
      @pie_labels_journals << User.find(user_id).firstname + " #{@user_retro_hash[user_id]["percentage_journals"].to_s}%"
    end


    @max_range = @max_journals if @max_journals > @max_range

    #Total voting activity
    @total_votes = @retro.issue_votes.length
    @pie_data_votes = []
    @pie_labels_votes = []
    @max_votes = 0
    votes_group = @retro.issue_votes.group_by{|issue_vote| issue_vote.user_id}
    votes_group.keys.sort.each do |user_id|
      next if user_id == User.sysadmin.id
      @user_retro_hash.store user_id, new_user_retro.dup unless @user_retro_hash.has_key? user_id
      @user_retro_hash[user_id].store "votes", votes_group[user_id]
      @user_retro_hash[user_id].store "total_votes", votes_group[user_id].length
      @user_retro_hash[user_id].store "percentage_votes", (@user_retro_hash[user_id]["total_votes"].to_f / @total_votes * 100).round_to(0).to_i
      @max_votes = @user_retro_hash[user_id]["total_votes"] if @user_retro_hash[user_id]["total_votes"] > @max_votes
      @pie_data_votes << @user_retro_hash[user_id]["percentage_votes"]
      @pie_labels_votes << User.find(user_id).firstname + " #{@user_retro_hash[user_id]["percentage_votes"].to_s}%"
    end


    #Total ideas
    @total_ideas = @retro.issues.length
    @pie_data_ideas = []
    @pie_labels_ideas = []


    author_group.keys.sort.each do |author_id|
      next if author_id == User.sysadmin.id
      percentage = (@user_retro_hash[author_id]["total_ideas"].to_f / @total_ideas * 100).round_to(0).to_i
      @pie_data_ideas << percentage
      @pie_labels_ideas << User.find(author_id).firstname + " #{percentage.to_s}%"
    end


    @max_range = @max_votes if @max_votes > @max_range

    #Build Chart
    @point_totals = []
    @vote_totals = []
    @journal_totals = []
    @idea_totals = []
    @axis_labels = []
    x_axis = ''


    @user_retro_hash.keys.sort.each do |user_id|
      @point_totals << @user_retro_hash[user_id]["total_points"]
      @vote_totals << @user_retro_hash[user_id]["total_votes"]
      @journal_totals << @user_retro_hash[user_id]["total_journals"]
      @idea_totals << @user_retro_hash[user_id]["total_ideas"]
      x_axis = x_axis + User.find(user_id).firstname + '|'
    end
    @axis_labels << x_axis

    #Average time taken to complete a point?


    respond_to do |format|
      format.html { render :layout => 'blank'}# show.html.erb
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
        flash.now[:success] = 'Retro was successfully created.'
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
        flash.now[:success] = 'Retro was successfully updated.'
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

  def find_retro
    @retro = Retro.find(params[:id])
    @project = @retro.project
    render_message l(:text_project_locked) if @project.locked?
  end


  def find_project
      @project = Project.find(params[:project_id])
      render_message l(:text_project_locked) if @project.locked?
  end
end
