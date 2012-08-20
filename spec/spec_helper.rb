require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/autorun'
  require 'spec/rails'
  require 'factory_girl'

  require File.dirname(__FILE__) + "/factories"

  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

  Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    def login
      @user = Factory.create(:user)
      User.stub(:current).and_return @user
    end
  end
end

Spork.each_run do

end
