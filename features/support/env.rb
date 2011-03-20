ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

Cucumber::Rails::World.use_transactional_fixtures = false

ActionController::Base.allow_rescue = false

require 'cucumber'
require 'cucumber/formatter/unicode'
require 'cucumber/rails/rspec'

require 'webrat'
require 'webrat/core/matchers' 

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = true
end

Cucumber::Rails::World.class_eval do 
  def skip_teardown?; ENV.include? "SKIP_TEARDOWN"; end
  def teardown(&block) 
    (@teardowns ||= []) << block
  end
end

After do
  unless skip_teardown? 
    @teardowns.each {|proc| proc.call} unless @teardowns.nil?
  end
end
