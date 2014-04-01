require 'spec_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.server_boot_timeout = 30

Spec::Runner.configure do |config|
  config.include Capybara::DSL
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def log_info(*args); end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
