# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.

# activity_stream.rb provides the model ActivityStream

class ActivityStream < ActiveRecord::Base

  # status levels, for generating activites that don't display
  VISIBLE   = 0     # Noraml visible activity
  DEBUG     = 1     # Test activity used for debugginng
  INTERNAL  = 2     # Internal system activity
  DELETED   = 3     # A deleted activity (soft delete)

  belongs_to :actor, :polymorphic => true
  belongs_to :object, :polymorphic => true
  belongs_to :indirect_object, :polymorphic => true
  belongs_to :project
  
  # Finds the recent activities for a given actor, and honors
  # the users activity_stream_preferences.  Please see the README
  # for an example usage.
  def self.recent_actors(actor, location, limit=12)

    unless actor.class.name == ACTIVITY_STREAM_USER_MODEL
      find(:all, :conditions => 
        {:actor_id => actor.id, 
        :actor_type => actor.class.name, 
        :status => 0}, :order => "created_at DESC", :limit => limit,
        :include => [:actor, :object, :indirect_object])

    else
      # FIXME: We really want :include => [:actor, :object], however, when
      # the "p.id" => nil condition prevents polymorphic :include from working
      find(:all, 
        :joins => self.preference_join(location),
        :conditions => [
          'actor_id = ? and actor_type = ? and status = ? and p.id IS NULL',
          actor.id, actor.class.name, 0 ],
        :order => "created_at DESC",
        :limit => limit)
    end
  end  

  # Finds the recent activities for a given actor, and honors
  # the users activity_stream_preferences.  Please see the README
  # for a sample usage.
  def self.recent_objects(object, location, limit=12)
    # FIXME: We really want :include => [:actor, :object], however, when
    # the "p.id" => nil condition prevents polymorphic :include from working
    find(:all, 
      :joins => self.preference_join(location),
      :conditions => [
          "object_id = ? and object_type = ? and status = ? and p.id IS NULL", 
          object.id, object.class.name, 0 ],
      :order => "created_at DESC",
      :limit => limit)
  end  

  def self.preference_join(location) # :nodoc:
    # location is not tainted as it is a symbol from
    # the code
    "LEFT OUTER JOIN activity_stream_preferences p \
      ON #{ACTIVITY_STREAM_USER_MODEL_ID} = actor_id  \
      AND actor_type = '#{ACTIVITY_STREAM_USER_MODEL}'  \
      AND activity_streams.activity = p.activity \
      AND location = '#{location.to_s}'"
  end
  
  def self.fetch(user_id, project, with_subprojects, limit)
    
    length = Setting::ACTIVITY_STREAM_LENGTH
    
    if limit
      begin; @length = params[:length].to_i; rescue; end
    end
    
    with_subprojects ||= true
    
    conditions = {}
    conditions[:actor_id] = user_id unless user_id.nil?
    conditions[:project_id] = project.id if project && !with_subprojects
    conditions[:project_id] = project.sub_project_array if project && with_subprojects
    
    activities_by_item = ActivityStream.all(:conditions => conditions, :limit => length).group_by {|a| a.object_type + a.object_id.to_s}
    activities_by_item.each_pair do |key,value| 
      activities_by_item[key] = value.sort_by{|i| - i[:updated_at].to_i}
    end
    
    activities_by_item.sort_by{|g| - g[1][0][:updated_at].to_i}
  end

  # Soft Delete in as some activites are necessary for site stats
  def soft_destroy
    self.update_attribute(:status, DELETED)
  end

  # # The "Name" fo the actor based on the actor_name_method passed into 
  # # the activity_stream_log controller method
  # def actor_name
  #   self.actor.nil? ? '' : self.actor.send(self.actor_name_method)
  # end
  # 
  # # The "Name" fo the object based on the object_name_method passed into 
  # # the activity_stream_log controller method
  # def object_name
  #   self.object.nil? ? '' : self.object.send(self.object_name_method)
  # end

end
