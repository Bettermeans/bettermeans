#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# activity_stream_preferences_module.rb provides ActivityStreamPreferencesModule

require 'digest/sha1'

# ActivityStreamPreferencesModule is included in your generated ActivityStreamPereference Controller and provides functionality for User to configure preferences as to where their activities are displayed
module ActivityStreamPreferencesModule
  # GET /activity_stream_preferences
  # GET /activity_stream_preferences.xml
  # GET /activity_stream_preferences?user_id=N   # Admin only
  def index

    get_user_id

    @activity_stream_preferences = ActivityStreamPreference.find(:all, 
      :conditions => { ACTIVITY_STREAM_USER_MODEL_ID => @user_id })

    build_activities_hash

    klass = Object::const_get(ACTIVITY_STREAM_USER_MODEL)
    @user = klass.find(@user_id)
    if @user.activity_stream_token.blank?
      @user.update_attribute(:activity_stream_token,
        Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ))
      if @user.id == self.current_user.id
        self.current_user.reload
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_stream_preferences }
    end
  end

  # POST /activity_stream_preferences
  # POST /activity_stream_preferences.xml
  def create

    get_user_id

    @activity_stream_preferences = ActivityStreamPreference.find(:all, 
      :conditions => { ACTIVITY_STREAM_USER_MODEL_ID => @user_id })

    build_activities_hash

    locations = params[:locations] || []

    all_locations = []

    ACTIVITY_STREAM_LOCATIONS.each do |location|
      ACTIVITY_STREAM_ACTIVITIES.each_key do |activity|
        all_locations <<  "#{activity.to_s}.#{location[0]}"
      end
    end

    (all_locations - locations).each do |location|
      activity = @activities[location]
      if activity
        @activities.delete(location)
        next
      end
      activity = ActivityStreamPreference.new
      (activity_name,location_id) = location.split('.')
      activity.activity = activity_name
      activity.location = location_id
      activity.send("#{ACTIVITY_STREAM_USER_MODEL_ID}=", @user_id)
      activity.save!
    end

    @activities.each_value { |a| a.destroy }

    respond_to do |format|
      flash[:notice] = 'Activity Stream Preferences were successfully updated.'
      format.html do
        if current_user.admin? && params[ACTIVITY_STREAM_USER_MODEL_ID.to_sym] != current_user.id.to_s
          redirect_to(activity_stream_preferences_path(ACTIVITY_STREAM_USER_MODEL_ID => @user_id))
        else
          redirect_to(activity_stream_preferences_path)
        end
      end
      format.xml  { head :ok }
    end
  end

protected

  def get_user_id
    if current_user.admin? && params[ACTIVITY_STREAM_USER_MODEL_ID.to_sym] 
      @user_id = params[ACTIVITY_STREAM_USER_MODEL_ID.to_sym]
    else
      @user_id = current_user.id
    end
  end

  def build_activities_hash
    @activities = {}
    @activity_stream_preferences.each do |a|
      key = "#{a.activity}.#{a.location}"
      @activities[key] = a
    end
  end

end
