require 'recurly' 

Recurly.configure do |c|
  # c.username = 'recurly-api@bettermeans.com'
  # c.password = 'd893b5c0b61142f9af4729bc6e831e7d'
  # c.site = 'https://bettermeans-test.recurly.com'
  c.username = ENV['RECURLY_USERNAME']
  c.password = ENV['RECURLY_PASSWORD']
  c.site = 'https://bettermeans.recurly.com'
end