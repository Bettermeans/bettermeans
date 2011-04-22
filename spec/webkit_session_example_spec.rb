require "spec_helper"

require "features/support/webkit_session.rb"

describe WebkitSession,"#click" do
  before :each do 
    @driver = stub("A fake driver")  
  end
  
  it "fails if the element cannot be found" do
    session = WebkitSession.new @driver
    
    @driver.stub(:find).once.and_return []
    
    lambda{session.click "xxx"}.should raise_error "Unable to locate element <xxx>"
  end
  
  it "fails if there are multiple elements found" do 
    session = WebkitSession.new @driver
    
    @driver.stub(:find).once.and_return [Object.new,Object.new]
    
    lambda{session.click "xxx"}.should raise_error "Too many elements found. Expected <1>. Got <2>."  
  end
  
  it "you can click anything"
end

describe WebkitSession,"#find" do
  before :each do 
    @driver = stub("A fake driver")  
  end
  
  it "tries to find elements by id, name and value" do
    element_identifier = "xxx"
    
    @driver.should_receive(:find).with("//*[@id='#{element_identifier}']").and_return [] 
    @driver.should_receive(:find).with("//*[@name='#{element_identifier}']").and_return [] 
    @driver.should_receive(:find).with("//*[@value='#{element_identifier}']").and_return [] 
    
    session.find element_identifier
  end
  
  it "returns nil if element cannot be found by id, name or value" do 
    element_identifier = "xxx"
    
    @driver.should_receive(:find).with("//*[@id='#{element_identifier}']").and_return [] 
    @driver.should_receive(:find).with("//*[@name='#{element_identifier}']").and_return [] 
    @driver.should_receive(:find).with("//*[@value='#{element_identifier}']").and_return [] 
    
    result = session.find element_identifier
    result.should be_nil
  end
  
  def session; @session ||= WebkitSession.new @driver; end
end

describe WebkitSession do
  it "resets its driver when get is called"
  it "clears all scope when get is called"
  it "supplies a dummy 'response' argument (not nil) when invoking Webrat::Scope.from_page to stop response caching error"
end