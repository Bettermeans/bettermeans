require File.dirname(__FILE__) + '/spec_helper'
require 'action_controller'
require File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'rails')

if ActionController::Base.respond_to?(:rescue_from)
  # pre 2.0 versions of rails don't have rescue_from so there's no contention
  class MyException < Exception;end
  class SpecialException < Exception;end

  class RescueFromController < ActionController::Base
    rescue_from MyException, :with => :my_handler

    def my_handler
      true
    end
  end

  describe "Exceptional with rescue_from() support" do
    before(:each) do
      @controller = RescueFromController.new
    end

    it "should not call Exceptional" do
      @controller.should_receive(:rescue_action_without_exceptional).and_return(true)
      if Gem::Requirement.create(">=2.2.0").satisfied_by?(Gem.loaded_specs['rails'].version)
        Exceptional.should_not_receive(:handle)
      else
        Exceptional.should_receive(:handle)
      end
      @controller.send(:rescue_action, MyException.new("test")).should == true
    end

    it "should call Exceptional" do
      Exceptional.should_receive(:handle)
      @controller.should_receive(:rescue_action_without_exceptional).and_return(true)
      @controller.send(:rescue_action, SpecialException.new("test")).should == true
    end
  end
end