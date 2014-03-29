require 'spec_helper'
require 'capybara/rails'

Spec::Runner.configure do |config|
  config.include Capybara::DSL
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
