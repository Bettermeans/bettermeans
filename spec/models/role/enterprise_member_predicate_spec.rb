require 'spec_helper'

describe Role, '#enterprise_member?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if level is enterprise" do
    role.level = Role::LEVEL_ENTERPRISE
    role.enterprise_member?.should be true
  end

  it "returns false if level is not enterprise" do
    role.level = Role::LEVEL_PLATFORM
    role.enterprise_member?.should be false
  end

end
