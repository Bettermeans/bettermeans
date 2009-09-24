class VoteFuGenerator < Rails::Generator::Base 

  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'vote_fu_migration'
    end 
  end
end
