require 'yaml'

module Exceptional
  module Config

    # Defaults for configuration variables
    REMOTE_HOST = "getexceptional.com"
    REMOTE_PORT = 80
    REMOTE_SSL_PORT = 443
    SSL = false
    LOG_LEVEL = 'info'
    LOG_PATH = nil

    class ConfigurationException < StandardError; end

    attr_reader :api_key
    attr_writer :ssl_enabled, :remote_host, :remote_port, :api_key

    def setup_config(environment, config_file)
      begin
        config = YAML::load(File.open(config_file))[environment]
        @api_key = config['api-key'] unless config['api-key'].nil?
        @ssl_enabled = config['ssl'] unless config['ssl'].nil?
        @log_level = config['log-level'] unless config['log-level'].nil?
        @enabled = config['enabled'] unless config['enabled'].nil?
        @remote_port = config['remote-port'].to_i unless config['remote-port'].nil?
        @remote_host = config['remote-host'] unless config['remote-host'].nil?
        @applicaton_root = application_root

        log_config_info
      rescue Exception => e
        raise ConfigurationException.new("Unable to load configuration #{config_file} for environment #{environment} : #{e.message}")
      end
    end

    def application_root
      @applicaton_root || (File.dirname(__FILE__) + '/../..')
    end

    def remote_host
      @remote_host || REMOTE_HOST
    end

    def remote_port
      @remote_port || default_port
    end

    def log_level
      @log_level || LOG_LEVEL
    end

    def default_port
      ssl_enabled? ? REMOTE_SSL_PORT : REMOTE_PORT
    end

    def ssl_enabled?
      @ssl_enabled || SSL
    end

    def enabled?
      @enabled || false
    end

    def valid_api_key?
      @api_key && @api_key.length == 40 ? true : false
    end

    def log_config_info
      Exceptional.to_log('debug', "API Key: #{api_key}")
      Exceptional.to_log('debug', "Remote Host: #{remote_host}:#{remote_port}")
      Exceptional.to_log('debug', "Log level: #{log_level}")
    end
  end
end