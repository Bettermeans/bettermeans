require 'spec_helper'

describe Role, '#contributor?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is contributor" do
    role.builtin = Role::BUILTIN_CONTRIBUTOR
    role.contributor?.should be true
  end

  it "returns false if builtin is not contributor" do
    role.builtin = Role::BUILTIN_ADMINISTRATOR
    role.contributor?.should be false
  end

end
