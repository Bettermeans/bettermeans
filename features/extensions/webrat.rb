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