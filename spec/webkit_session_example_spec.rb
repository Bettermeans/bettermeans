require "spec_helper"

require "features/support/webkit_session.rb"

describe WebkitSession,"#click" do
  it "fails if the element cannot be found" do
    stub_driver = stub("A fake driver")
    session = WebkitSession.new stub_driver
    
    stub_driver.stub(:find).once.and_return []
    
    lambda{session.click "xxx"}.should raise_error "Unable to locate element <xxx>"
  end
  
  it "fails if there are multiple elements found"
  it "you can click anything"
end

describe WebkitSession do
  it "resets its driver when get is called"
  it "clears all scope when get is called"
  it "Tries to find elements by id, name and value"
  it "supplies a dummy 'response' argument (not nil) when invoking Webrat::Scope.from_page to stop response caching error"
end