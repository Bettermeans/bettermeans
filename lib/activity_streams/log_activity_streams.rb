#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file
# LICENSE included with this ActivityStreams plug-in.
#++
# The LogActivityStreams module adds a controller class method and
# helper for automatically logging activity streams.
#
# README provides examples
module LogActivityStreams

  include ActivityStreamsHelper

  def self.write_single_activity_stream(actor,actor_name,object,object_name,verb,activity, status, indirect_object, options)
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
    as.project_id = options[:project_id] || object.send('project_id')
    as.project_name = Project.find(as.project_id).name


    #Pre-generating text
    as.actor_name = actor.send(actor_name)
    as.object_name = object.send(object_name)
    as.object_description = object.send(options[:object_description_method]) if options[:object_description_method]

    if as.object_type == "Issue"
      as.tracker_name = as.object.tracker.name

      #hiding gifts
      if as.object.tracker.gift?
        as.hidden_from_user_id = as.object.assigned_to_id
        as.is_public = false
      end
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

  def self.find_identical(actor, object, verb, activity) # :nodoc:
    return nil unless object.respond_to?(:project_id)
    ActivityStream.find(:first, :conditions => [
      'actor_id = ? AND actor_type = ? AND object_id = ? AND object_type = ? AND verb = ? AND activity = ? AND updated_at >= ? AND project_id = ? AND status = 0',
      actor.id, actor.class.name, object.id, object.class.name, verb.to_s,
      activity.to_s, Time.now - 8.hours, object.project_id])
  end


  def self.included(controller) #:nodoc:
    controller.extend(ClassMethods)
    controller.helper_method :activity_stream_location
  end

  module ClassMethods #:nodoc:

    # log_activity_streams writes the activity stream from a controller.
    #
    # README provides examples of how to call log_activity_streams
    def log_activity_streams(actor_method, actor_name, verb, object_method,
      object_name, action, activity, options={})

      self.after_filter do |c|
        c.send(:write_activity_stream_log, actor_method, actor_name, verb, object_method, object_name, action, activity, options)
      end

    end
  end

  protected

  # activity_stream_location is a helper method for determing the current 'location' (public, logged in users).
  #
  #  Example:
  #        <%= render :partial => 'activity_streams/activity_stream', :collection => ActivityStream.recent_actors(@user, activity_stream_location)  %>
  #
  def activity_stream_location
    if not logged_in?
      :public_location
    else
      :logged_in_location
    end
  end

  def write_activity_stream_log(actor_method, actor_name, verb, object_method,
    object_name, action, activity, options={}) #:nodoc:

    return unless action == self.action_name.to_sym

    return if !flash.now[:error].blank? || @suppress_activity_stream

    status = options[:status] || 0

    if actor_method.to_s.start_with?('@')
      actors = self.instance_variable_get(actor_method) || []
    else
      actors = self.send(actor_method) || []
    end
    actors = [ actors ] unless actors.is_a? Array
    return if actors.empty? || actors.first == :false

    if object_method.to_s.start_with?('@')
      objects = self.instance_variable_get(object_method) || []
    else
      objects = self.send(object_method) || []
    end
    objects = [ objects ] unless objects.is_a? Array


    if indirect_object_method = options[:indirect_object]

      if indirect_object_method.to_s.start_with?('@')
        indirect_object = self.instance_variable_get(indirect_object_method)
      else
        indirect_object = self.send(indirect_object_method)
      end
    end

    actors.each do |actor|
      objects.each do |object|

        # ensure no errors on object, as a validation error would mean no
        # activity should fire
        next unless object.errors.empty?

        LogActivityStreams.write_single_activity_stream(actor,actor_name,object,object_name,verb,activity,status,indirect_object, options)

        total = options[:total]
        if total
          total_for = options[:total_for] || :actor
          if total_for == :actor
            target = actor
          else
            target = object
          end

          if total.is_a? Symbol
            if total.to_s.start_with?('@')
              total = self.instance_variable_get(total)
            else
              total = self.send(total) || []
            end
          end
          activity_stream_total = ActivityStreamTotal.find(:first,
              :conditions => { :activity => activity,
              :object_id => target.id,
              :object_type => target.class.name}
             ) || ActivityStreamTotal.new(:object => target,
              :activity => activity)
          activity_stream_total.total += total
          activity_stream_total.save!
        end
      end
    end
  end

end
