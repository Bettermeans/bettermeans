require 'spec_helper'

describe Role, '#has_permission?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if permission exists" do
    role.add_permission!('read', 'write')
    role.has_permission?('read').should == true
  end

  it "returns false if permission does not exist" do
    role.add_permission!('write')
    role.has_permission?('read').should == false
  end

end
