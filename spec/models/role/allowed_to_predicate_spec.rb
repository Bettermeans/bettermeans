require 'spec_helper'

describe Role, '#allowed_to?' do

  let(:role) { Role.create({:name => 'role'}) }

  before(:each) do
    Redmine::AccessControl.stub(:allowed_actions).and_return(['foo/bar'])
    Redmine::AccessControl.stub(:public_permissions).and_return([OpenStruct.new(:name => 'bar')])
  end

  context "when parameter is a hash" do
    it "returns true if the controller action is permitted" do
      role.allowed_to?({:controller => 'foo', :action => 'bar'}).should be true
    end

    it "returns false if the controller action is not permitted" do
      role.allowed_to?({:controller => 'foo', :action => 'notbar'}).should be false
    end
  end

  context "when parameter is not a hash" do
    it "returns true if the action is permitted" do
      role.allowed_to?('bar').should be true
    end

    it "returns false if the aciton is not permitted" do
      role.allowed_to?('notbar').should be false
    end
  end

end
