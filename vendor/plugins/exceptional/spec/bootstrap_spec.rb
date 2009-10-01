require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Bootstrap do
  describe "setup" do
    TEST_ENVIRONMENT= "development"

    it "should initialize the config and log" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end

    it "should authenticate if enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:authenticate).and_return(true)
      STDERR.should_not_receive(:puts) #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end

    it "should not authenticate if not enabled" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(false)
      Exceptional.should_not_receive(:authenticate)
      STDERR.should_not_receive(:puts) # Will silently not enable itself

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end

    it "should report to STDERR if authentication fails" do
      Exceptional.should_receive(:setup_config)
      Exceptional.should_receive(:setup_log)
      Exceptional.should_receive(:enabled?).and_return(true)
      Exceptional.should_receive(:authenticate).and_return(false)
      STDERR.should_receive(:puts) #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end

    it "should report to STDERR if error during config initialization" do
      Exceptional.should_receive(:setup_config).and_raise(Exceptional::Config::ConfigurationException)
      Exceptional.should_not_receive(:setup_log)
      Exceptional.should_not_receive(:authenticate).and_return(false)
      STDERR.should_receive(:puts).twice() #Should be no errors to report

      Exceptional.bootstrap(TEST_ENVIRONMENT, File.dirname(__FILE__))
    end
  end
end