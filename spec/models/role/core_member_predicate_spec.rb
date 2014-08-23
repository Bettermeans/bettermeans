require 'spec_helper'

describe Role, '#core_member?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is a core member" do
    role.builtin = Role::BUILTIN_CORE_MEMBER
    role.core_member?.should be true
  end

  it "returns false if builtin is not core member" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.core_member?.should be false
  end

end
