# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class BoardsController < ApplicationController
  default_search_scope :messages
  before_filter :find_project, :authorize
  ssl_required :all

  helper :messages
  include MessagesHelper
  helper :sort
  include SortHelper
  helper :watchers
  include WatchersHelper

  def index
    @boards = @project.boards
    # show the board if there is only one
    if @boards.size == 1
      @board = @boards.first
      show
    end
  end

  def show
    respond_to do |format|
      format.html {
        sort_init 'updated_at', 'desc'
        sort_update 'created_at' => "#{Message.table_name}.created_at",
                    'replies' => "#{Message.table_name}.replies_count",
                    'updated_at' => "#{Message.table_name}.updated_at"

        @topic_count = @board.topics.count
        @topic_pages = Paginator.new self, @topic_count, per_page_option, params['page']
        @topics =  @board.topics.find :all, :order => ["#{Message.table_name}.sticky DESC", sort_clause].compact.join(', '),
                                      :include => [:author, {:last_reply => :author}],
                                      :limit  =>  @topic_pages.items_per_page,
                                      :offset =>  @topic_pages.current.offset
        @message = Message.new
        render :action => 'show', :layout => !request.xhr?
      }
    end
  end

  verify :method => :post, :only => [ :destroy ], :redirect_to => { :action => :index }

  def new
    @board = Board.new(params[:board])
    @board.project = @project
    if request.post? && @board.save
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'boards'
    end
  end

  def edit
    if request.post? && @board.update_attributes(params[:board])
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'boards'
    end
  end

  def destroy
    @board.destroy
    redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'boards'
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
    render_message l(:text_project_locked) if @project.locked?
    @board = @project.boards.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
