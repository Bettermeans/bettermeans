module SingleLogActivityStreams
  
  include ActivityStreamsHelper
  
  def write_single_activity_stream(actor,actor_name,object,object_name,verb,activity, status, indirect_object, options)
  # If there are identical activities within 8 hours, up count
  activity_stream = find_identical(actor, object, verb, activity);

  if activity_stream
    activity_stream.count += 1
  else
    activity_stream = ActivityStream.new
    activity_stream.verb = verb.to_s
    activity_stream.activity = activity.to_s
    activity_stream.actor = actor
    activity_stream.actor_name_method = actor_name.to_s
    activity_stream.object = object
    activity_stream.object_name_method = object_name.to_s
    activity_stream.status = status
    activity_stream.project_id = object.send('project_id')
    
    #Pre-generating text
    activity_stream.actor_name = actor.send(actor_name)
    activity_stream.object_name = object.send(object_name)
    activity_stream.object_description = object.send(options[:object_description_method]) if options[:object_description_method]
    
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
    
    if indirect_object
      activity_stream.indirect_object = indirect_object
      activity_stream.indirect_object_name_method = options[:indirect_object_name_method].to_s
      activity_stream.indirect_object_phrase = options[:indirect_object_phrase]
      if options[:indirect_object_description_method]
          activity_stream.indirect_object_description = indirect_object.send(options[:indirect_object_description_method]) 
      end
    end
  end
  
  activity_stream.save!
   
  end
  
  def find_identical(actor, object, verb, activity) # :nodoc:
    logger.info("actor #{actor} object #{object}")
    ActivityStream.find(:first, :conditions => [
      'actor_id = ? AND actor_type = ? AND object_id = ? AND object_type = ? AND verb = ? AND activity = ? AND updated_at >= ? AND project_id = ? AND status = 0', 
      actor.id, actor.class.name, object.id, object.class.name, verb.to_s, 
      activity.to_s, Time.now - 8.hours, object.project_id])
  end
    
end