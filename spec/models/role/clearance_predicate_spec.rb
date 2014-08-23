require 'spec_helper'

describe Role, '#clearance?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is clearance" do
    role.builtin = Role::BUILTIN_CLEARANCE
    role.clearance?.should be true
  end

  it "returns false if builtin is not clearance" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.clearance?.should be false
  end

end
