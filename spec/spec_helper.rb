require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/rails'
  require 'factory_girl'

  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

  Spec::Runner.configure do |config|
    Spec::Rails::Example::ControllerExampleGroup.integrate_views
    config.use_transactional_fixtures = false
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      FakeWeb.allow_net_connect = %r[^https?://127\.0\.0\.1]
      load_seeds
    end

    config.before(:each) do
      DatabaseCleaner.strategy = :truncation if integration?
      DatabaseCleaner.start
    end

    config.after(:each) do
      Capybara.reset! if integration?
      DatabaseCleaner.clean
      DatabaseCleaner.strategy = :transaction
      load_seeds if integration?
    end
  end

  def load_seeds
    load File.dirname(__FILE__) + '/../db/seeds.rb'
  end

  def integration?
    self.class.to_s.match(/IntegrationExampleGroup/)
  end

  def cleaner_strategy
    active_record_cleaner.instance_variable_get(:@strategy).class
  end

  def active_record_cleaner
    DatabaseCleaner.instance_variable_get(:@cleaners)[[:active_record, {}]]
  end

  def login_as(user)
    session[:user_id] = user.id
  end

end

Spork.each_run do

end
