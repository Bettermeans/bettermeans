ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

Cucumber::Rails::World.use_transactional_fixtures = false

ActionController::Base.allow_rescue = false

require 'cucumber'
require 'cucumber/formatter/unicode'
require 'cucumber/rails/rspec'
#require "#{Rails.root}/spec/factories"

require 'webrat'
require 'webrat/core/matchers' 

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = true # Set to true if you want error pages to pop up in the browser
end
