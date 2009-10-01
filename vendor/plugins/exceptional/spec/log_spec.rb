require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Log do

  TEST_LOG_MESSAGE = "Test-log-message"

  it "uninitialized should only log to STDERR" do
    STDERR.should_receive(:puts)
    Logger.should_not_receive(:send)
    Exceptional.log! TEST_LOG_MESSAGE
  end

  it "initialized should log to both STDERR and log file" do
    mock_log = mock("log")
    mock_log.should_receive(:level=)
    
    Logger.should_receive(:new).and_return(mock_log)

    Exceptional.setup_log File.dirname(File.join(File.dirname(__FILE__), ".."))
    
    Exceptional.log.should_receive(:send).with("info", TEST_LOG_MESSAGE)
    STDERR.should_receive(:puts)

    Exceptional.log! TEST_LOG_MESSAGE
  end
end
