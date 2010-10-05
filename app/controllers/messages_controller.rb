# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

class MessagesController < ApplicationController
  menu_item :boards
  default_search_scope :messages
  before_filter :find_board, :only => [:new, :preview]
  before_filter :find_message, :except => [:new, :preview, :motion_reply]
  before_filter :authorize, :except => [:preview, :edit, :destroy]
  # before_filter :guess_board, :only => [:show]
  ssl_required :all  
  

  verify :method => :post, :only => [ :reply, :destroy ], :redirect_to => { :action => :show }
  verify :xhr => true, :only => :quote

  helper :watchers
  helper :attachments
  include AttachmentsHelper   
  
  log_activity_streams :current_user, :name, :created, :@message, :subject, :new, :messages, {:object_description_method => :content}
  log_activity_streams :current_user, :name, :edited, :@message, :subject, :edit, :messages, {:object_description_method => :content}
            # :indirect_object_name_method => :to_s,
            # :indirect_object_phrase => ' ' }

  log_activity_streams :current_user, :name, :replied_to, :@topic, :subject, :reply, :messages, {
            :object_description_method => :content,
            :indirect_object => :@reply,
            :indirect_object_description_method => :content,
            :indirect_object_phrase => '' }
  

  # Show a topic and its replies
  def show
    @replies = @topic.children.find(:all, :include => [:author, :attachments, {:board => :project}])
    @replies.reverse! if User.current.wants_comments_in_reverse_order?
    @reply = Message.new(:subject => "RE: #{@message.subject}")
    render :action => "show", :layout => false if request.xhr?
  end
  
  # Create a new topic
  def new
    @message = Message.new(params[:message])
    @message.author = User.current
    @message.board = @board
    if params[:message] && User.current.allowed_to?(:edit_messages, @project)
      @message.locked = params[:message]['locked']
      @message.sticky = params[:message]['sticky']
    end
    if request.post? && @message.save
      attach_files(@message, params[:attachments])
      redirect_to :action => 'show', :id => @message
    end
  end

  # Reply to a topic
  def reply
    @reply = Message.new(params[:reply])
    @reply.subject = @message.subject if @reply.subject == ""
    @reply.author = User.current
    @reply.board = @board
    @topic.children << @reply
    if !@reply.new_record?
      attach_files(@reply, params[:attachments])
    end
    respond_to do |wants|
      wants.html { redirect_to :action => 'show', :id => @topic  }
      wants.js { render :nothing => :true}
    end
  end

  # Edit a message
  def edit
    (render_403; return false) unless @message.editable_by?(User.current)
    if params[:message]
      @message.locked = params[:message]['locked']
      @message.sticky = params[:message]['sticky']
    end
    if request.post? && @message.update_attributes(params[:message])
      attach_files(@message, params[:attachments])
      flash.now[:notice] = l(:notice_successful_update)
      @message.reload
      redirect_to :action => 'show', :board_id => @message.board, :id => @message.root
    end
  end
  
  # Delete a messages
  def destroy
    (render_403; return false) unless @message.destroyable_by?(User.current)
    @message.destroy
    redirect_to @message.parent.nil? ?
      { :controller => 'boards', :action => 'show', :project_id => @project, :id => @board } :
      { :action => 'show', :id => @message.parent }
  end
  
  def quote
    user = @message.author
    text = @message.content
    subject = @message.subject.gsub('"', '\"')
    subject = "RE: #{subject}" unless subject.starts_with?('RE:')
    content = "#{ll(Setting.default_language, :text_user_wrote, user)}\\n> "
    content << text.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]').gsub('"', '\"').gsub(/(\r?\n|\r\n?)/, "\\n> ") + "\\n\\n"
    render(:update) { |page|
      page << "$('reply_subject').value = \"#{subject}\";"
      page.<< "$('message_content').value = \"#{content}\";"
      page.show 'reply'
      page << "$('#message_content').focus();"
      page << "$('body').scrollTo('#reply');"
      # page << "$('message_content').scrollTop = $('message_content').scrollHeight - $('message_content').clientHeight;"
    }
  end
  
  def preview
    message = @board.messages.find_by_id(params[:id])
    @attachements = message.attachments if message
    @text = (params[:message] || params[:reply])[:content]
    render :partial => 'common/preview'
  end
  
private
  def find_message
    if params[:board_id] == 'guess'
      logger.info { "guessing board" }
      guess_board
    else
      find_board
      @message = @board.messages.find(params[:id], :include => :parent)
    end
    @topic = @message.root unless @message.nil?
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  #This function is used to redirect links coming from the activity stream
  #To save queries on the database, we don't try to load the board id in the link to a message
  def guess_board
    @message = Message.find(params[:id], :include => :parent)
    @board = @message.board
    @project = @board.project
    logger.info { "guessed board #{@board.inspect}" }
    # redirect_to :action => "show", :board_id => @board.id, :id => params[:id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  
  def find_board
    @board = Board.find(params[:board_id], :include => :project)
    @project = @board.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
