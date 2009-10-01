require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::ExceptionData do
  describe "with valid base data" do
    before(:each) do
      exception = mock('Exception', :backtrace => "/var/www/app/fail.rb:42 Error('There was an error')", :message => "There was an error", :class => 'Error')
      @exception_data = Exceptional::ExceptionData.new(exception)
    end
    
    it "language should be ruby" do
      @exception_data.language.should == "ruby"
    end
    
    it "should be valid" do
      @exception_data.should be_valid
    end

    it "should convert to hash" do
      @exception_data.to_hash.should == {:exception_class => "Error", :exception_message => "There was an error",
                                         :exception_backtrace => "/var/www/app/fail.rb:42 Error('There was an error')",
                                         :language => "ruby"}
    end
        
    it "should convert to json" do
      @exception_data.to_json.class.should == String
    end
  end
end