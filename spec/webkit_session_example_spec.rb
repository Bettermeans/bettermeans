require "spec_helper"

require "features/support/webkit_session.rb"

describe WebkitSession do
  it "resets its driver when get is called"
  it "clears all scope when get is called"
  it "supplies a dummy 'response' argument (not nil) when invoking Webrat::Scope.from_page to stop response caching error"
  
  it "click_button fails unless the specified thing can be found"
  it "you can click anything"
end