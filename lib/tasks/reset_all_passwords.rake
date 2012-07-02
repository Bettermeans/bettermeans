task :reset_all_passwords => :environment do

  if ENV['reset_safe'] == 'true'
    puts "Resetting all passwords to 'password'..."
    User.update_all(:hashed_password => "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8")
    # User.update_all(:hashed_password => "")
    puts "done."
  else
    puts "wont reset. we're not in development"
    puts "to allow reset use: export reset_safe=true"
  end
end
