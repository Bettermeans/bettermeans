module SingleLogActivityStreams
  
  include ActivityStreamsHelper
  
  def write_single_activity_stream(actor,actor_name,object,object_name,verb,activity, status, indirect_object, options)
  # If there are identical activities within 8 hours, up count
  as = find_identical(actor, object, verb, activity);

  if as && !(as.object_type.downcase == 'issue' && as.indirect_object_description != nil) #if action was found, and action is NOT a comment on an issue)
    as.count += 1
  else
    as = ActivityStream.new
    as.verb = verb.to_s
    as.activity = activity.to_s
    as.actor = actor
    as.actor_name_method = actor_name.to_s
    as.actor_email = "<#{actor.mail}>"
    as.object = object
    as.object_name_method = object_name.to_s
    as.status = status
    as.project_id = object.send('project_id')
    as.project_name = Project.find(as.project_id).name
    
    
    #Pre-generating text
    as.actor_name = actor.send(actor_name)
    as.object_name = object.send(object_name)
    as.object_description = object.send(options[:object_description_method]) if options[:object_description_method]
    
    if as.object_type == "Issue"
      as.tracker_name = as.object.tracker.name
    end
    
    
    if indirect_object
      as.indirect_object = indirect_object
      as.indirect_object_name_method = options[:indirect_object_name_method].to_s
      as.indirect_object_phrase = options[:indirect_object_phrase]
      if options[:indirect_object_name_method]
          as.indirect_object_name = indirect_object.send(options[:indirect_object_name_method]) 
      end

      if options[:indirect_object_description_method]
          as.indirect_object_description = indirect_object.send(options[:indirect_object_description_method]) 
      end
    end
  end
  
  as.save!
   
  end
  
  def find_identical(actor, object, verb, activity) # :nodoc:
    logger.info("actor #{actor} object #{object}")
    ActivityStream.find(:first, :conditions => [
      'actor_id = ? AND actor_type = ? AND object_id = ? AND object_type = ? AND verb = ? AND activity = ? AND updated_at >= ? AND project_id = ? AND status = 0', 
      actor.id, actor.class.name, object.id, object.class.name, verb.to_s, 
      activity.to_s, Time.now - 8.hours, object.project_id])
  end
    
end