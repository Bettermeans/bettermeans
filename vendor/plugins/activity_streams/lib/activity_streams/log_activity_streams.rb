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

    return if !flash[:error].blank? || @suppress_activity_stream

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

        # If there are identical activities within 8 hours, up count
        activity_stream = ActivityStream.find_identical(actor, object, verb, 
          activity);

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
          if indirect_object
            activity_stream.indirect_object = indirect_object
            activity_stream.indirect_object_name_method = options[:indirect_object_name_method].to_s
            activity_stream.indirect_object_phrase = options[:indirect_object_phrase]
          end
        end

        activity_stream.save!

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
