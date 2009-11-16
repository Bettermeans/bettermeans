Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :selenium
end

Cucumber::Rails::World.use_transactional_fixtures = false

require 'database_cleaner'
DatabaseCleaner.clean_with :truncation # clean once to ensure clean slate
DatabaseCleaner.strategy = :truncation

Before('@no-txn') do
  DatabaseCleaner.start
end

After('@no-txn') do
  DatabaseCleaner.clean
end