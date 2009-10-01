# This is the post install hook for when Exceptional is installed as a plugin.
require 'ftools'

# puts IO.read(File.join(File.dirname(__FILE__), 'README'))

config_file = File.expand_path("#{File.dirname(__FILE__)}/../../../config/exceptional.yml")
example_config_file = "#{File.dirname(__FILE__)}/exceptional.yml"

if File::exists? config_file
  puts "Exceptional config file already exists. Please ensure it is up-to-date with the current format."
  puts "See #{example_config_file}"
else  
  puts "Installing default Exceptional config"
  puts "  From #{example_config_file}"
  puts "For exceptional to work you need to configure your API Key"
  puts "  See #{example_config_file}"
  puts "If you don't have an API Key, get one at http://getexceptional.com/"
  File.copy example_config_file, config_file
end
