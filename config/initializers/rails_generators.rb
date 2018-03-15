## https://www.lucascaton.com.br/2014/02/28/have-a-rails-2-app-you-can-run-it-on-the-newest-ruby/

## This is a very important monkey patch to make Rails 2.3.18 to work with Ruby 2+
## If you're thinking to remove it, really, don't, unless you know what you're doing.

if Rails::VERSION::MAJOR == 2 && RUBY_VERSION >= '2.0.0'
  require 'rails_generator'
  require 'rails_generator/scripts/generate'

  Rails::Generator::Commands::Create.class_eval do
    def template(relative_source, relative_destination, template_options = {})
      file(relative_source, relative_destination, template_options) do |file|
        # Evaluate any assignments in a temporary, throwaway binding
        vars = template_options[:assigns] || {}
        b = template_options[:binding] || binding

        # this no longer works, eval throws "undefined local variable or method `vars'"
        # vars.each { |k, v| eval "#{k} = vars[:#{k}] || vars['#{k}']", b }
        vars.each { |k, v| b.local_variable_set(:"#{k}", v) }

        # Render the source file with the temporary binding
        ERB.new(file.read, nil, '-').result(b)
      end
    end
  end
end
