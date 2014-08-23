require 'spec_helper'

describe Role, '#member?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is member" do
    role.builtin = Role::BUILTIN_MEMBER
    role.member?.should be true
  end

  it "returns false if builtin is not member" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.member?.should be false
  end

end
