AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['s3_access_key_id'],
  :secret_access_key => ENV['s3_secret_access_key']
)
