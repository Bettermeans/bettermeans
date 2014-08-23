require 'spec_helper'

describe Role, '#builtin?' do

  let(:role) { Role.create({:name => 'role'}) }

  it "returns true if builtin is in the COMMUNITY_ROLES" do
    Role::COMMUNITY_ROLES.each do |role_id|
      role.builtin = role_id
      role.builtin?.should be true
    end
  end

  it "returns false if builtin is not in the COMMUNITY_ROLES" do
    role.builtin = Role::NON_BUILTIN_ROLE
    role.builtin?.should be false
  end

end
