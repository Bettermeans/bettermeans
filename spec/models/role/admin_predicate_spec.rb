require 'spec_helper'

describe Role, '#admin?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is admin" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.admin?.should be true
  end

  it "returns false if builtin is not admin" do
    role.builtin = Role::BUILTIN_NON_MEMBER
    role.admin?.should be false
  end

end
