require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Config do
  before(:all) do
    def Exceptional.reset_state
      @api_key = nil
      @ssl_enabled = nil
      @log_level = nil
      @enabled = nil
      @remote_port = nil
      @remote_host = nil
      @applicaton_root = nil
    end
  end

  after(:each) do
    Exceptional.reset_state
  end
  
  before(:each) do
    Exceptional.stub!(:log!) # Don't even attempt to log
    Exceptional.stub!(:to_log)  
  end
  
  describe "default configuration" do
    it "should use port 80 by default if ssl not enabled" do
      Exceptional.ssl_enabled?.should be_false
      Exceptional.remote_port.should == 80
    end

    it "should use port 443 if ssl enabled" do
      Exceptional.ssl_enabled= true
      Exceptional.remote_port.should == 443
      Exceptional.ssl_enabled= false
    end

    it "should use log level of info by default" do
      Exceptional.log_level.should == "info"
    end

    it "should not be enabled by default" do
      Exceptional.enabled?.should be_false
    end

    it "should overwrite default host" do
      Exceptional.remote_host.should == "getexceptional.com"
      Exceptional.remote_host = "localhost"
      Exceptional.remote_host.should == "localhost"
    end

    it "should overwrite default port" do
      Exceptional.remote_port.should == 80

      Exceptional.remote_port = 3000
      Exceptional.remote_port.should == 3000
      Exceptional.remote_port = nil
    end
    
    it "api_key should by default be in-valid" do
      Exceptional.valid_api_key?.should be_false
    end    
  end

  describe "load config" do
    it "error during config file loading raises configuration exception" do
      File.should_receive(:open).once.and_raise(IOError)
      
      lambda{Exceptional.setup_config("development", File.dirname(__FILE__))}.should raise_error(Exceptional::Config::ConfigurationException)
    end

    it "is enabled for production environment" do
      Exceptional.enabled?.should be_false

      Exceptional.setup_config "production", File.join(File.dirname(__FILE__), "/../exceptional.yml")
      Exceptional.enabled?.should be_true
    end

    it "is enabled by default for production and staging environments" do
      Exceptional.enabled?.should be_false

      Exceptional.setup_config "production", File.join(File.dirname(__FILE__), "/../exceptional.yml")
      Exceptional.enabled?.should be_true

      Exceptional.reset_state
      Exceptional.enabled?.should be_false

      Exceptional.setup_config "staging", File.join(File.dirname(__FILE__), "/../exceptional.yml")
      Exceptional.enabled?.should be_true
    end

    it "is disabled by default for development & test environments" do
      Exceptional.enabled?.should be_false

      Exceptional.setup_config "development", File.join(File.dirname(__FILE__), "/../exceptional.yml")
      Exceptional.enabled?.should be_false

      Exceptional.reset_state
      Exceptional.enabled?.should be_false

      Exceptional.setup_config "test", File.join(File.dirname(__FILE__), "/../exceptional.yml")
      Exceptional.enabled?.should be_false
    end            
  end
end