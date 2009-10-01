module Exceptional
  module Bootstrap
    
    # called from init.rb
    def bootstrap(environment, application_root)
      begin
        setup_config(environment, File.join(application_root,"config", "exceptional.yml"))
        setup_log(File.join(application_root, "log"), log_level)

        if enabled?
          if authenticate
            require File.join('exceptional', 'integration', 'rails')
          else
            STDERR.puts "Exceptional plugin not authenticated, check your API Key"
          end
        end
      rescue Exception => e
        STDERR.puts e
        STDERR.puts "Exceptional Plugin disabled."
      end
    end
  end
end
