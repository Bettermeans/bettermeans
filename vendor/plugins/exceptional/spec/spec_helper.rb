require 'rubygems'
begin
  require 'ginger'
rescue LoadError
end

gem 'rails'
require File.dirname(__FILE__) + '/../lib/exceptional'