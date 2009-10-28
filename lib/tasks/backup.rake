

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
  
  config = YAML.load(File.open("#{RAILS_ROOT}/config/s3.yml"))[RAILS_ENV]
  AWS::S3::Base.establish_connection!(
      :access_key_id => config['access_key_id'],
      :secret_access_key => config['secret_access_key']
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

