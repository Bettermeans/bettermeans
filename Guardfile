guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch('config/routes.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{^spec/factories/.+\.rb$})
  watch('db/seeds.rb')
  watch(%r{features/support/}) { :cucumber }
  watch(%r{^app/models/.+\.rb$})
  watch(%r{^app/controllers/.+\.rb$})
end

guard 'rspec', :version => 1, :cli => '--drb --color', :all_on_start => false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')

  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+_controller)\.rb$})  { |m| ["spec/controllers/#{m[1]}/", "spec/controllers/#{m[1]}_controller_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/integration/#{m[1]}_spec.rb" }
  watch(%r{^spec/integration/(.+)_spec\.rb$})
end
