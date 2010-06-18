task :reset_all_passwords => :environment do

    puts "Resetting all passwords..."
    User.update_all(:hashed_password => "5d2817668058ae738cecdc4254b9ce0b60a825a7")
    puts "done."
end