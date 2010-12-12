task :bootstrap => :environment do
  
  puts "Creating db..."
  Rake::Task['db:create'].invoke
  
  puts "Loading schema..."
  Rake::Task['db:schema:load'].invoke
  
  puts "Seeding..."
  Rake::Task['db:seed'].invoke
  
  puts "Creating admin"
  user = User.new :firstname => "Redmine",:lastname => "Admin",:mail => "admin@example.net",:mail_notification => true,:language => "en",:status => 1
  user.admin = true
  user.hashed_password = "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8" #admin password is 'password'
  user.login = "admin"
  user.save
end
