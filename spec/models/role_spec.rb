require 'spec_helper'

describe Role do
  let(:role) { Role.create({:name => 'role'}) }
  describe '#permissions' do
    context 'permissions attribute exists' do
      it 'returns array of permissions' do
        role.permissions = ['read', 'write']
        role.permissions.should == [:read, :write]
      end
    end

    context 'permissions attribute does not exist' do
      it 'returns blank array' do
        role.permissions.should == []
      end
    end
  end

  describe '#permissions=' do
    context 'parameters are nil' do
      it 'sets permissions to nil' do
        role.permissions = ['read', 'write']
        role.permissions = nil
        role.permissions.should == []
      end
    end

    context 'identical parameters exist' do
      it 'should set permissions uniquely' do
        role.permissions = ['read', 'read', 'write']
        role.permissions.should == [:read, :write]
      end
    end
  end

  describe '#add_permission!' do
    it 'adds each parameter to permissions' do
      role.add_permission!('read', 'write')
      role.reload.permissions.should == [:read, :write]
    end
  end

  describe '#remove_permission!' do
    it 'removes specified permissions' do
      role.add_permission!('read', 'write')
      role.remove_permission!('read')
      role.permissions.should == [:write]
    end
  end

  describe '#has_permission?' do
    it "returns true if permission exists" do
      role.add_permission!('read', 'write')
      role.has_permission?('read').should == true
    end

    it "returns false if permission does not exist" do
      role.add_permission!('write')
      role.has_permission?('read').should == false
    end
  end

  describe '#to_s' do
    it 'returns the name' do
      role.to_s.should == 'role'
    end
  end

  describe '#builtin?' do
    it "returns true if builtin is not 0" do
      Role::COMMUNITY_ROLES.each do |role_id|
        role.builtin = role_id
        role.should be_builtin
      end
    end

    it "returns false if builtin is 0" do
      role.builtin = Role::NON_BUILTIN_ROLE
      role.should_not be_builtin
    end
  end

  describe "#community_member?" do
    context "when builtin is a community role" do
      it "returns true" do
        Role::COMMUNITY_ROLES.each do |role_id|
          role.builtin = role_id
          role.should be_community_member
        end
      end
    end
  end

  describe "#enterprise_member?" do
    it "returns true if level is enterprise" do
      role.level = Role::LEVEL_ENTERPRISE
      role.should be_enterprise_member
    end

    it "returns false if level is not enterprise" do
      role.level = Role::LEVEL_PLATFORM
      role.should_not be_enterprise_member
    end
  end

  describe "#platform_member?" do
    it "returns true if level is platform" do
      role.level = Role::LEVEL_PLATFORM
      role.should be_platform_member
    end

    it "returns false if level is not 0" do
      role.level = Role::LEVEL_ENTERPRISE
      role.should_not be_platform_member
    end
  end

  describe "#binding_member?" do
    it "returns true if builtin is in binding members" do
      Role::BINDING_MEMBERS.each do |role_id|
        role.builtin = role_id
        role.should be_binding_member
      end
    end

    it "returns false if builtin is not in [3,4,8]" do
      role.builtin = 1
      role.should_not be_binding_member
    end
  end

  describe "#admin?" do
    it "returns true if builtin is 3" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should be_admin
    end

    it "returns false if builtin is not admin" do
      role.builtin = Role::BUILTIN_NON_MEMBER
      role.should_not be_admin
    end
  end

  describe "#core_member?" do
    it "returns true if builtin is a core member" do
      role.builtin = Role::BUILTIN_CORE_MEMBER
      role.should be_core_member
    end

    it "returns false if builtin is not core member" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should_not be_core_member
    end
  end

  describe "#contributor?" do
    it "returns true if builtin is contributor" do
      role.builtin = Role::BUILTIN_CONTRIBUTOR
      role.should be_contributor
    end

    it "returns false if builtin is not contributor" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should_not be_contributor
    end
  end

  describe "#member?" do
    it "returns true if builtin is member" do
      role.builtin = Role::BUILTIN_MEMBER
      role.should be_member
    end

    it "returns false if builtin is not member" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should_not be_member
    end
  end

  describe "#active?" do
    it "returns true if builtin is active" do
      role.builtin = Role::BUILTIN_ACTIVE
      role.should be_active
    end

    it "returns false if builtin is not 7" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should_not be_active
    end
  end

  describe "#clearance?" do
    it "returns true if builtin is clearance" do
      role.builtin = Role::BUILTIN_CLEARANCE
      role.should be_clearance
    end

    it "returns false if builtin is not 10" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.should_not be_clearance
    end
  end

  describe "#allowed_to?" do
    module Redmine
      module AccessControl
        def self.allowed_actions(permission)
          ['foo/bar']
        end

        def self.public_permissions
          [OpenStruct.new(:name => 'bar')]
        end
      end
    end
    context "when parameter is a hash" do
      it "returns true if the controller action is permitted" do
        role.should be_allowed_to({:controller => 'foo', :action => 'bar'})
      end

      it "returns false if the controller action is not permitted" do
        role.should_not be_allowed_to({:controller => 'foo', :action => 'notbar'})
      end
    end

    context "when parameter is not a hash" do
      it "returns true if the action is permitted" do
        role.should be_allowed_to('bar')
      end

      it "returns false if the aciton is not permitted" do
        role.should_not be_allowed_to('notbar')
      end
    end
  end
end
