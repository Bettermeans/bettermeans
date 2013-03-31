require 'timeout'

module Delayed

  class DeserializationError < StandardError
  end

  # A job object that is persisted to the database.
  # Contains the work object as a YAML field.
  class Job < ActiveRecord::Base
    set_table_name :delayed_jobs

    named_scope :ready_to_run, lambda {|worker_name, max_run_time|
      {:conditions => ['(run_at <= ? AND (locked_at IS NULL OR locked_at < ?) OR locked_by = ?) AND failed_at IS NULL', db_time_now, db_time_now - max_run_time, worker_name]}
    }
    named_scope :by_priority, :order => 'priority DESC, run_at ASC'

    ParseObjectFromYaml = /\!ruby\/\w+\:([^\s]+)/

    # When a worker is exiting, make sure we don't have any locked jobs.
    def self.clear_locks!(worker_name)
      update_all("locked_by = null, locked_at = null", ["locked_by = ?", worker_name])
    end

    def failed?
      failed_at
    end
    alias_method :failed, :failed?

    def payload_object
      @payload_object ||= deserialize(self['handler'])
    end

    def name
      @name ||= begin
        payload = payload_object
        if payload.respond_to?(:display_name)
          payload.display_name
        else
          payload.class.name
        end
      end
    end

    def payload_object=(object)
      self['handler'] = object.to_yaml
    end

    # Add a job to the queue
    def self.enqueue(*args)
      object = args.shift
      unless object.respond_to?(:perform)
        raise ArgumentError, 'Cannot enqueue items which do not respond to perform'
      end

      priority = args.first || 0
      run_at   = args[1]

      Job.create(:payload_object => object, :priority => priority.to_i, :run_at => run_at)
    end

    # Find a few candidate jobs to run (in case some immediately get locked by others).
    def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
      scope = self.ready_to_run(worker_name, max_run_time)
      scope = scope.scoped(:conditions => ['priority >= ?', Worker.min_priority]) if Worker.min_priority
      scope = scope.scoped(:conditions => ['priority <= ?', Worker.max_priority]) if Worker.max_priority

      ActiveRecord::Base.silence do
        scope.by_priority.all(:limit => limit)
      end
    end

    # Lock this job for this worker.
    # Returns true if we have the lock, false otherwise.
    def lock_exclusively!(max_run_time, worker)
      now = self.class.db_time_now
      affected_rows = if locked_by != worker
        # We don't own this job so we will update the locked_by name and the locked_at
        self.class.update_all(["locked_at = ?, locked_by = ?", now, worker], ["id = ? and (locked_at is null or locked_at < ?) and (run_at <= ?)", id, (now - max_run_time.to_i), now])
      else
        # We already own this job, this may happen if the job queue crashes.
        # Simply resume and update the locked_at
        self.class.update_all(["locked_at = ?", now], ["id = ? and locked_by = ?", id, worker])
      end
      if affected_rows == 1
        self.locked_at    = now
        self.locked_by    = worker
        return true
      else
        return false
      end
    end

    # Unlock this job (note: not saved to DB)
    def unlock
      self.locked_at    = nil
      self.locked_by    = nil
    end

    # Moved into its own method so that new_relic can trace it.
    def invoke_job
      payload_object.perform
    end

  private

    def deserialize(source)
      handler = YAML.load(source) rescue nil

      unless handler.respond_to?(:perform)
        if handler.nil? && source =~ ParseObjectFromYaml
          handler_class = $1
        end
        attempt_to_load(handler_class || handler.class)
        handler = YAML.load(source)
      end

      return handler if handler.respond_to?(:perform)

      raise DeserializationError,
        'Job failed to load: Unknown handler. Try to manually require the appropriate file.'
    rescue TypeError, LoadError, NameError => e
      raise DeserializationError,
        "Job failed to load: #{e.message}. Try to manually require the required file."
    end

    # Constantize the object so that ActiveSupport can attempt
    # its auto loading magic. Will raise LoadError if not successful.
    def attempt_to_load(klass)
       klass.constantize
    end

    # Get the current time (GMT or local depending on DB)
    # Note: This does not ping the DB to get the time, so all your clients
    # must have syncronized clocks.
    def self.db_time_now
      if Time.zone
        Time.zone.now
      elsif ActiveRecord::Base.default_timezone == :utc
        Time.now.utc
      else
        Time.now
      end
    end

  protected

    def before_save
      self.run_at ||= self.class.db_time_now
    end

  end
end
