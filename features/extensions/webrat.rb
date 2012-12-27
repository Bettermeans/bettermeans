Webrat.module_eval do
  def self.session_class
    if Webrat.configuration.mode == :selenium
      Webrat::SeleniumSession
    elsif Webrat.configuration.mode == :webkit
      WebkitSession
    else
      Webrat::Session
    end
  end
end

Webrat::Scope.class_eval do
  # Eliminates response caching so ajax can work
  def dom # :nodoc:
    if @selector
      return scoped_dom
    else
      return page_dom
    end
  end
end