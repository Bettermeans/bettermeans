require File.dirname(__FILE__) + '/spec_helper'
require 'net/http'

describe Exceptional::Remote do

  TEST_API_KEY = "TEST_API_KEY"

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

    def Exceptional.reset_authentication
      @authenticated = false
    end
  end

  after(:each) do
    Exceptional.reset_state
    Exceptional.reset_authentication
  end

  describe "authentication" do
    it "should not be authenticated if API authentication unsuccessful" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:call_remote, {:method => "authenticate", :data => ""}).once.and_return("false")
      Exceptional.authenticate.should be_false
      Exceptional.authenticated?.should be_false
    end

    it "should not be authenticated if error during API authenticate" do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:call_remote, {:method => "authenticate", :data => ""}).once.and_raise(IOError)

      Exceptional.authenticate.should be_false
      Exceptional.authenticated?.should be_false
    end

    it "should not re-authenticate subsequently if 1 successful " do
      Exceptional.api_key = TEST_API_KEY

      Exceptional.authenticated?.should be_false
      Exceptional.should_receive(:call_remote, {:method => "authenticate", :data => ""}).once.and_return("true")
      # If authentication is successful, authenticate called only once

      Exceptional.authenticate.should be_true
      Exceptional.authenticated?.should be_true

      Exceptional.authenticate.should be_true
      Exceptional.authenticated?.should be_true
    end

    it "with no API Key set throws Configuration Exception" do
      Exceptional.authenticated?.should be_false

      lambda {Exceptional.authenticate}.should raise_error(Exceptional::Config::ConfigurationException)
    end
  end

  describe "sending data " do
    it "should return response body if successful" do
      OK_RESPONSE_BODY = "OK-RESP-BODY"
      
      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(true)
      mock_http_response.should_receive(:body).once.and_return(OK_RESPONSE_BODY)

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      Exceptional.post_exception("data").should == OK_RESPONSE_BODY
    end
    
    it "should raise error if network problem during sending exception" do
      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPSuccess)

      mock_http.should_receive(:start).once.and_raise(IOError)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).twice

      lambda{Exceptional.post_exception("data")}.should raise_error(IOError) 
    end

    it "should raise Exception if sending exception unsuccessful" do
      Exceptional.api_key = TEST_API_KEY
      Exceptional.authenticated?.should be_false

      Exceptional.should_receive(:authenticated?).once.and_return(true)

      mock_http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with("getexceptional.com", 80).once.and_return(mock_http)

      mock_http_response= mock(Net::HTTPInternalServerError)
      mock_http_response.should_receive(:kind_of?).with(Net::HTTPSuccess).once.and_return(false)
      mock_http_response.should_receive(:code).once.and_return(501)
      mock_http_response.should_receive(:message).once.and_return("Internal Server Error")

      mock_http.should_receive(:start).once.and_return(mock_http_response)

      #surpress the logging of the exception
      Exceptional.should_receive(:log!).twice

      lambda{Exceptional.post_exception("data")}.should raise_error(Exceptional::Remote::RemoteException) 
    end    
  end
end
