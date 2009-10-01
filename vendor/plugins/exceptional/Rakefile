begin
  require 'echoe'

  Echoe.new('exceptional', '0.0.6') do |p|
    p.rubyforge_name = 'exceptional'
    p.summary = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
    p.description = "Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)"
    p.url = "http://getexceptional.com/"
    p.author = ["Contrast"]
    p.email = "hello@contrast.ie"
    p.dependencies = ["json"]
  end
rescue LoadError => e
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{e.to_s.capitalize}."
end
# add spec tasks, if you have rspec installed
begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new("spec") do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color']
  end

  task :test do
    Rake::Task['spec'].invoke
  end

  Spec::Rake::SpecTask.new("coverage") do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color']
    t.rcov = true
    t.rcov_opts = ['--exclude', '^spec,/gems/']
  end
end

desc 'Run specs using ginger'
task :ginger do
  ARGV.clear
  ARGV << 'spec'
  load File.join(*%w[bin ginger])
end