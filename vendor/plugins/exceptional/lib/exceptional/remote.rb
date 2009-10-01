require 'zlib'
require 'cgi'
require 'net/http'

module Exceptional
  module Remote

    class RemoteException < StandardError; end

    ::PROTOCOL_VERSION = 3

    # authenticate with getexceptional.com
    # returns true if the configured api_key is registered and can send data
    # otherwise false
    def authenticate

      return @authenticated if @authenticated

      if Exceptional.api_key.nil?
        raise Exceptional::Config::ConfigurationException.new("API Key must be configured")
      end

      begin
        # TODO No data required to authenticate, send a nil string? hacky
        # TODO should retry if a http connection failed
        authenticated = call_remote(:authenticate, "")
        
        @authenticated = authenticated =~ /true/ ? true : false
      rescue
        @authenticated = false
      ensure
        return @authenticated
      end
    end

    def authenticated?
      @authenticated || false
    end

    def post_exception(data)
      if !authenticated?
        authenticate
      end

      call_remote(:errors, data)
    end

    protected

    def call_remote(method, data)
      begin
        http = Net::HTTP.new(Exceptional.remote_host, Exceptional.remote_port)
        http.use_ssl = true if Exceptional.ssl_enabled?
        uri = "/#{method.to_s}?&api_key=#{Exceptional.api_key}&protocol_version=#{::PROTOCOL_VERSION}"
        headers = method.to_s == 'errors' ? { 'Content-Type' => 'application/x-gzip', 'Accept' => 'application/x-gzip' } : {}

        compressed_data = CGI::escape(Zlib::Deflate.deflate(data, Zlib::BEST_SPEED))
        response = http.start do |http|
          http.post(uri, compressed_data, headers)
        end

        if response.kind_of? Net::HTTPSuccess
          return response.body
        else
          raise RemoteException.new("#{response.code}: #{response.message}")
        end

      rescue Exception => e
        Exceptional.log! "Error contacting Exceptional: #{e}", 'info'
        Exceptional.log! e.backtrace.join("\n"), 'debug'
        raise e
      end
    end
  end
end