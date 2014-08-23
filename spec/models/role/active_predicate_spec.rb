require 'spec_helper'

describe Role, '#active?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is active" do
    role.builtin = Role::BUILTIN_ACTIVE
    role.active?.should be true
  end

  it "returns false if builtin is not active" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.active?.should be false
  end

end
