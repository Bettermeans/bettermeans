AWS::S3::Base.establish_connection!({
  :access_key_id     => ENV['BETTER_S3_ACCESS_KEY_ID'],
  :secret_access_key => ENV['BETTER_S3_SECRET_ACCESS_KEY']
})
