require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/autorun'
  require 'spec/rails'
  require 'factory_girl'

  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

  Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    config.before :suite do
      FakeWeb.allow_net_connect = false
      load File.dirname(__FILE__) + '/../db/seeds.rb'
    end

    config.after :suite do
      FakeWeb.allow_net_connect = true
    end
  end

  def login
    @user = Factory.create(:user)
    User.stub(:current).and_return @user
  end
end

Spork.each_run do

end
