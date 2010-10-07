# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

#For ruby debug
SCRIPT_LINES__ = {} if ENV['RAILS_ENV'] == 'development'


# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load Engine plugin if available
begin
  require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
rescue LoadError
  # Not available
end

Rails::Initializer.run do |config|
    
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for sweepers
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :message_observer, :issue_observer, :journal_observer, :news_observer, :document_observer, :wiki_content_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby
  
  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  # config.action_mailer.perform_deliveries = false
  
  #Added this to bypass error
  config.action_controller.session = { :key => "_bettermeans_session", :secret => "95fd75499b43ada8cfbc538558d74312asdf" }

  config.gem 'rubytree', :lib => 'tree'
  
  config.gem "rpx_now"
  
  config.after_initialize do # so rake gems:install works
    RPXNow.api_key = ENV['RPXNOW_KEY']
  end
  
  config.gem "recurly"
  
  config.gem "fleximage"

  config.gem 'reportable', :lib => 'saulabs/reportable'  
  
  config.gem 'crafterm-comma', :lib => 'comma'
  
  config.gem 'fastercsv'
  
    
  # Load any local configuration that is kept out of source control
  # (e.g. gems, patches).
  if File.exists?(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
    instance_eval File.read(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
  end  
  
  class Hash
    def +(hash2)
      hash2.each do |key, value|
        if self.has_key? key
          self[key] += value 
        else
          self[key] = value
        end
      end
    end
    
    def to_array_conditions
      @new_conditions = []
      @new_conditions[0] = self.map {|k,v| v.class.to_s == "Array" ? "#{k} in (?)" : "#{k} = ?"}.join(" AND ")
      self.values.each do |v|
        v.type.to_s == "Array" ? @new_conditions.push(v.flatten) : @new_conditions.push("#{v}")
      end
      @new_conditions
      #[self.each.map {|k,v| v.type.to_s == "Array" ? "#{k} in (?)" : "#{k} = ?"}.join(" AND "), self.values.map {|v| v.type.to_s == "Array" ? v.flatten : "#{v}"}]

      
      # [self.keys.map{|k| "#{k} = ?" }.join(" AND "), self.values].flatten
      
    end
  end
  
    
end


