require 'redmine'
require 'dispatcher' # Patches to the Redmine core.
 
Dispatcher.to_prepare :redmine_s3 do

  # RedmineS3::Connection.create_bucket
end

Redmine::Plugin.register :redmine_s3_attachments do
  name 'S3'
  author 'Chris Dell'
  description 'Use Amazon S3 as a storage engine for attachemnts'
  version '0.0.2'
end
