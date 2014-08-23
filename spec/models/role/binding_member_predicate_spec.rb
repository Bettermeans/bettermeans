require 'spec_helper'

describe Role, '#binding_member?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is in binding members" do
    Role::BINDING_MEMBERS.each do |role_id|
      role.builtin = role_id
      role.binding_member?.should be true
    end
  end

  it "returns false if builtin is not in binding members" do
    role.builtin = 1
    role.binding_member?.should be false
  end

end
