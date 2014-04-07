require 'spec_helper'
require 'capybara/rails'

Capybara.default_driver = :webkit
Capybara.default_wait_time = 10
Capybara.server_boot_timeout = 30

Spec::Runner.configure do |config|
  config.include Capybara::DSL
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def log_info(*args); end
end

def disable_help
  HelpSection.stub(:first).and_return(double(:show => false))
end

def render_page
  page.driver.render("#{Rails.root}/test_out.png")
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
