source 'https://rubygems.org'

ruby '1.8.7'

gem 'rake', '0.8.7'

gem 'rails', '2.3.18'

gem 'SystemTimer', '1.2.2', :require => 'system_timer', :platforms => :ruby_18
gem 'comma', :git => 'https://github.com/crafterm/comma.git', :ref => 'rails2'
gem 'fastercsv', '1.5.4'
gem 'fleximage', '1.0.4'
gem 'foreigner'
gem 'grosser-ssl_requirement', :require => 'ssl_requirement'
gem 'honeybadger', :require => 'honeybadger/rails'
gem 'pg'
gem 'rack-timeout', '0.0.1'
gem 'recurly', '0.3.3'
gem 'reportable', '1.1.2'
gem 'rpx_now', '0.6.24'
gem 'ruby-debug', '0.10.4'
gem 'rubytree', '0.7.0'
gem 'will_paginate', '2.3.15'

group :test do
  # gem 'capybara', '~> 1.1.4'
  # gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'launchy'
  gem 'object_daddy', '0.4.3'
  gem 'rcov'
  gem 'rspec', '1.3.2'
  gem 'rspec-rails', '1.3.4'
  gem 'shoulda'
  gem 'steak'
  gem 'timecop', '0.6.1'
end

group :development do
  gem 'rb-inotify', '~> 0.8.8', :require => false
  gem 'rb-fsevent', :require => false
  gem 'brakeman', :require => false
  gem 'guard-rspec'
  gem 'spork', '0.8.5'
  gem 'guard-spork'
  gem 'childprocess', '0.3.6' # lock this down as it breaks guard-spork
  #gem 'reek'
  gem 'ruby2ruby', '1.2.2'
  gem 'heckle'
end

group :development, :test do
  gem 'factory_girl', '1.3.3'
  gem 'faker'
end
