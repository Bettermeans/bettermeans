# This class encapsulates data about an exception.
module Exceptional
  class DataError < StandardError; end
  
  class ExceptionData
    ::LANGUAGE = "ruby"
    ::BASE_ATTRS = [:exception_class, :exception_message, :exception_backtrace]
    ::OPTIONAL_ATTRS = [:framework, :controller_name, :action_name, :application_root, 
                        :url, :occurred_at, :environment, :session, :parameters]
    ::ACCESSIBLE_ATTRS = ::BASE_ATTRS + ::OPTIONAL_ATTRS
    ::ATTRS = [:language] + ::ACCESSIBLE_ATTRS
    
    ::ACCESSIBLE_ATTRS.each do |attribute|
      attr_accessor attribute
    end
    attr_reader   :language

    def initialize(exception)
      environment = {}
      session = {}
      parameters = {}
      self.exception_backtrace = exception.backtrace
      self.exception_message = exception.message
      self.exception_class = exception.class.to_s
      @language = ::LANGUAGE
    end
    
    def valid?
      ::BASE_ATTRS.each do |method|
        raise(DataError, "base data #{method} not set") if (self.send(method).nil? || self.send(method).empty?)
      end
    end
    
    def to_hash
      hash = {}
      ::ATTRS.each do |attribute|
        value = send(attribute)
        hash[attribute] = value unless (value.nil? || value.empty? || attribute.is_a?(TCPSocket) || attribute.is_a?(TCPServer)) 
      end
      hash
    end
    
    def to_json
      self.to_hash.to_json
    end    
  end
end