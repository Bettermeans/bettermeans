namespace :reek do
  task :statements do
    dirs_to_reek = ['app/models', 'app/controllers', 'app/helpers']
    files_to_reek = dirs_to_reek.map { |dir| Dir[File.join(dir, "**/*.rb")] }
    output = `reek #{files_to_reek.join(' ')}`
    long_methods = output.lines.select { |line| line =~ /TooManyStatements/ }
    long_methods.sort! do |line_1, line_2|
      line_1.split[3].to_i <=> line_2.split[3].to_i
    end
    puts long_methods
  end
end
