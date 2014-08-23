require 'spec_helper'

describe Role, '#community_member?' do

  let(:role) { Role.create({:name => 'role'}) }

  context "when builtin is a community role" do
    it "returns true" do
      Role::COMMUNITY_ROLES.each do |role_id|
        role.builtin = role_id
        role.community_member?.should be true
      end
    end
  end

end
