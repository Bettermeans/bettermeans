# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{exceptional}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Contrast"]
  s.date = %q{2009-07-09}
  s.description = %q{Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)}
  s.email = %q{hello@contrast.ie}
  s.extra_rdoc_files = ["lib/exceptional/api.rb", "lib/exceptional/bootstrap.rb", "lib/exceptional/config.rb", "lib/exceptional/exception_data.rb", "lib/exceptional/integration/rails.rb", "lib/exceptional/log.rb", "lib/exceptional/remote.rb", "lib/exceptional/version.rb", "lib/exceptional.rb", "README"]
  s.files = ["exceptional.gemspec", "exceptional.yml", "History.txt", "init.rb", "install.rb", "lib/exceptional/api.rb", "lib/exceptional/bootstrap.rb", "lib/exceptional/config.rb", "lib/exceptional/exception_data.rb", "lib/exceptional/integration/rails.rb", "lib/exceptional/log.rb", "lib/exceptional/remote.rb", "lib/exceptional/version.rb", "lib/exceptional.rb", "Manifest", "Rakefile", "README", "spec/api_spec.rb", "spec/bootstrap_spec.rb", "spec/config_spec.rb", "spec/exception_data_spec.rb", "spec/exceptional_rescue_from_spec.rb", "spec/exceptional_spec.rb", "spec/log_spec.rb", "spec/remote_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://getexceptional.com/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Exceptional", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{exceptional}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Exceptional is the core Ruby library for communicating with http://getexceptional.com (hosted error tracking service)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end