class NotificationsController < ApplicationController
  ssl_required :all
  def index
    @notifications = Notification.unresponded
    @mentions = @notifications.select {|n| n.mention?}
    @notifications = @notifications.select {|n| !n.mention?}

    respond_to do |format|
      format.html
      format.xml  { render :xml => @notifications }
    end
  end

  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @notification }
    end
  end

  def new
    @notification = Notification.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @notification }
    end
  end

  def edit
    @notification = Notification.find(params[:id])
  end

  def create
    @notification = Notification.new(params[:notification])

    respond_to do |format|
      if @notification.save
        flash.now[:success] = 'Notification was successfully created.'
        format.html { redirect_to(@notification) }
        format.xml  { render :xml => @notification, :status => :created, :location => @notification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to(@notification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def hide
    @notification = Notification.find(params[:notification_id])

    respond_to do |format|
      if @notification.mark_as_responded
        format.js {render :action => "hide"}
        format.xml  { head :ok }
      else
        flash.now[:success] = 'Error ignoring notification'
        format.js {render :action => "error"}
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end

end
