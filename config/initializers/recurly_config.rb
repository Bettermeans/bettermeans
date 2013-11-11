require 'recurly'

Recurly.configure do |c|
  c.username = ENV['RECURLY_USERNAME']
  c.password = ENV['RECURLY_PASSWORD']
  c.site     = ENV['RECURLY_SITE']
end
