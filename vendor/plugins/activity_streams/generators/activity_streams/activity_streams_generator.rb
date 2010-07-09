#--
# Copyright (c) 2008 Matson Systems, Inc.
# Released under the BSD license found in the file 
# LICENSE included with this ActivityStreams plug-in.
#++
# Generator for ActivityStreams.  For usage message do:
# ./script/genorator activity_streams
class ActivityStreamsGenerator < Rails::Generator::NamedBase
  attr_reader :user_model,
              :user_model_id,
              :user_model_table

    def initialize(runtime_args, runtime_options = {})
      super

      @user_model = args.shift || 'User'

      @user_model_table = @user_model.tableize
      @user_model_id = "#{@user_model.underscore}_id"

    end

  def manifest
    record do |m|

      #m.route_resources :activity_streams, :activity_stream_preferences

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
            :user_model =>  user_model,
            :user_model_table =>  user_model_table,
            :user_model_id =>  user_model_id,
            :migration_name => 'create_cactivity_streams'
        }, :migration_file_name => "create_activity_streams"
      end

      unless options[:skip_controllers]
        ["ActivityStreams", "ActivityStreamPreferences"].each do |c|
          m.template 'controller.rb',
            File.join('app/controllers', "#{c.tableize}_controller.rb"),
            :assigns => { :controller_name => c}
        end
      end

      unless options[:skip_tests]
        ["activity_stream_preferences_controller_test", 
         "activity_streams_controller_test"].each do |t|
          m.template "#{t}.rb",
            File.join('test/functional', "#{t}.rb"),
            :assigns => {
              :user_model =>  user_model,
              :user_model_table =>  user_model_table,
              :user_model_id =>  user_model_id,
            }
        end

        m.template 'activity_stream_preferences_integration_test.rb',
            File.join('test/integration', 
             'activity_stream_preferences_integration_test.rb'),
            :assigns => {
              :user_model =>  user_model,
              :user_model_table =>  user_model_table,
              :user_model_id =>  user_model_id,
            }

        m.template 'activity_stream_test.rb',
            File.join('test/unit', 
             'activity_stream_test.rb'),
            :assigns => {
              :user_model =>  user_model,
              :user_model_table =>  user_model_table,
              :user_model_id =>  user_model_id,
            }
        m.template 'activity_streams.yml',
            File.join('test/fixtures', 
             'activity_streams.yml')
      end

      unless options[:skip_initializer]
        m.template 'activity_streams.rb',
          File.join('config/initializers', "activity_streams.rb"),
            :assigns => { }
      end

    end
  end

  protected

  def banner
    "Usage: #{$0} activity_steams UserModelName"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration",
      "Don't generate a migration file for activity streams") { |v| 
        options[:skip_migration] = v }
    opt.on("--skip-controllers",
      "Don't generate controllers for activity streams") { |v| 
        options[:skip_controllers] = v }
    opt.on("--skip-tests",
      "Don't generate tests for activity streams") { |v| 
        options[:skip_tests] = v }
    opt.on("--skip-initializer",
      "Don't generate config/initializers/activity_streams.rb") { |v| 
        options[:skip_initializer] = v }
  end
  
end
