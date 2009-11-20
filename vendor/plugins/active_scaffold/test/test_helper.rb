require 'test/unit'
require 'rubygems'
require 'mocha'

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.join(File.dirname(__FILE__), 'mock_app')

require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config', 'environment.rb'))

def load_schema
  stdout = $stdout
  $stdout = StringIO.new # suppress output while building the schema
  load File.join(ENV['RAILS_ROOT'], 'db', 'schema.rb')
  $stdout = stdout
end

def silence_stderr(&block)
  stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr = stderr
end

for file in %w[model_stub const_mocker]
  require File.join(File.dirname(__FILE__), file)
end

ModelStub.connection.instance_eval do
  def quote_column_name(name)
    name
  end
end
