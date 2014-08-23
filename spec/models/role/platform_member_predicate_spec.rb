require 'spec_helper'

describe Role, '#platform_member?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if level is platform" do
    role.level = Role::LEVEL_PLATFORM
    role.platform_member?.should be true
  end

  it "returns false if level is not 0" do
    role.level = Role::LEVEL_ENTERPRISE
    role.platform_member?.should be false
  end

end
