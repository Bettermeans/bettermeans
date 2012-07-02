

# Heroku S3 Database backup task
# by Nick Merwin (Lemur Heavy Industries) 10.08.09
# * dumps db to yaml, gzip's and sends to S3
#
# Setup:
# 1) replace APP_NAME and BACKUP_BUCKET with your info
# 2) add config/s3.yml like so (same as Paperclip's):
# production:
# access_key_id: ...
# secret_access_key: ...
# 2) install the yaml_db plugin:
# script/plugin install git://github.com/adamwiggins/yaml_db.git
# 3) add aws-s3 to your .gems
#
# Usage:
# heroku rake backup
# rake backup remote=true # this will pull the db locally first
# * or add this to your cron.rake for hourly or nightly backups:
# Rake::Task['backup'].invoke
require 'aws/s3'

desc "backup db from heroku and send to S3"
task :backup => :environment do

  APP_NAME = 'bettermeans' # put your app name here
  BACKUP_BUCKET = 'heroku-db-bckps-bm' # put your backup bucket name here

  puts "Back up started @ #{Time.now}"

  puts "Pulling DB..."

  backup_name = "ew#{Time.now.to_i}.db"
  backup_path = "tmp/#{backup_name}"

  if ENV['remote'] == 'true'
    puts `heroku db:pull sqlite://#{backup_path} --app #{APP_NAME}`
  else
    YamlDb.dump backup_path
  end

  puts "gzipping db..."
  `gzip #{backup_path}`

  backup_name += ".gz"
  backup_path = "tmp/#{backup_name}"

  puts "Uploading #{backup_name} to S3..."

  # config = YAML.load(File.open("#{RAILS_ROOT}/config/s3.yml"))[RAILS_ENV]
  yaml_string = ERB.new(File.read("#{RAILS_ROOT}/config/s3.yml")).result
  options = YAML.load(yaml_string)

  puts "yaml string #{yaml_string}"
  puts "access key #{options[Rails.env]['access_key_id']}"
  puts "secret key #{options[Rails.env]['secret_access_key']}"

  AWS::S3::Base.establish_connection!(
      :access_key_id => options[Rails.env]['access_key_id'],
      :secret_access_key => options[Rails.env]['secret_access_key']
    )

  begin
    bucket = AWS::S3::Bucket.find BACKUP_BUCKET
  rescue AWS::S3::NoSuchBucket
    AWS::S3::Bucket.create BACKUP_BUCKET
    bucket = AWS::S3::Bucket.find BACKUP_BUCKET
  end

  AWS::S3::S3Object.store backup_name, File.read(backup_path), bucket.name, :content_type => 'application/x-gzip'

  puts "Done @ #{Time.now}"
end

namespace :heroku do
  desc "PostgreSQL database backups from Heroku to Amazon S3"
  task :daily_backup => :environment do
    begin
      require 'right_aws'
      puts "[#{Time.now}] heroku:backup started"
      name = "#{ENV['APP_NAME']}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.dump"
      db = ENV['DATABASE_URL'].match(/postgres:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)/)
      system "PGPASSWORD=#{db[2]} pg_dump -Fc --username=#{db[1]} --host=#{db[3]} #{db[4]} > tmp/#{name}"
      s3 = RightAws::S3.new(ENV['s3_access_key_id'], ENV['s3_secret_access_key'])
      bucket = s3.bucket("#{ENV['APP_NAME']}-heroku-backups", true, 'private')
      bucket.put(name, open("tmp/#{name}"))
      system "rm tmp/#{name}"
      puts "[#{Time.now}] heroku:backup complete"
    # rescue Exception => e
    # require 'toadhopper'
    # Toadhopper(ENV['hoptoad_key']).post!(e)
    end
  end
end

