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
      role.name = 'Core Team'
      role.to_s.should == 'Core Team'
    end
  end

  describe '#builtin?' do
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

  describe "#community_member?" do
    context "when builtin is a community role" do
      it "returns true" do
        Role::COMMUNITY_ROLES.each do |role_id|
          role.builtin = role_id
          role.community_member?.should be true
        end
      end
    end
  end

  describe "#enterprise_member?" do
    it "returns true if level is enterprise" do
      role.level = Role::LEVEL_ENTERPRISE
      role.enterprise_member?.should be true
    end

    it "returns false if level is not enterprise" do
      role.level = Role::LEVEL_PLATFORM
      role.enterprise_member?.should be false
    end
  end

  describe "#platform_member?" do
    it "returns true if level is platform" do
      role.level = Role::LEVEL_PLATFORM
      role.platform_member?.should be true
    end

    it "returns false if level is not 0" do
      role.level = Role::LEVEL_ENTERPRISE
      role.platform_member?.should be false
    end
  end

  describe "#binding_member?" do
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

  describe "#admin?" do
    it "returns true if builtin is admin" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.admin?.should be true
    end

    it "returns false if builtin is not admin" do
      role.builtin = Role::BUILTIN_NON_MEMBER
      role.admin?.should be false
    end
  end

  describe "#core_member?" do
    it "returns true if builtin is a core member" do
      role.builtin = Role::BUILTIN_CORE_MEMBER
      role.core_member?.should be true
    end

    it "returns false if builtin is not core member" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.core_member?.should be false
    end
  end

  describe "#contributor?" do
    it "returns true if builtin is contributor" do
      role.builtin = Role::BUILTIN_CONTRIBUTOR
      role.contributor?.should be true
    end

    it "returns false if builtin is not contributor" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.contributor?.should be false
    end
  end

  describe "#member?" do
    it "returns true if builtin is member" do
      role.builtin = Role::BUILTIN_MEMBER
      role.member?.should be true
    end

    it "returns false if builtin is not member" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.member?.should be false
    end
  end

  describe "#active?" do
    it "returns true if builtin is active" do
      role.builtin = Role::BUILTIN_ACTIVE
      role.active?.should be true
    end

    it "returns false if builtin is not active" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.active?.should be false
    end
  end

  describe "#clearance?" do
    it "returns true if builtin is clearance" do
      role.builtin = Role::BUILTIN_CLEARANCE
      role.clearance?.should be true
    end

    it "returns false if builtin is not clearance" do
      role.builtin = Role::BUILTIN_ADMINISTRATOR
      role.clearance?.should be false
    end
  end

  describe "#allowed_to?" do
    before(:each) do
      Redmine::AccessControl.stub(:allowed_actions).and_return(['foo/bar'])
      Redmine::AccessControl.stub(:public_permissions).and_return([OpenStruct.new(:name => 'bar')])
    end

    context "when parameter is a hash" do
      it "returns true if the controller action is permitted" do
        role.allowed_to?({:controller => 'foo', :action => 'bar'}).should be true
      end

      it "returns false if the controller action is not permitted" do
        role.allowed_to?({:controller => 'foo', :action => 'notbar'}).should be false
      end
    end

    context "when parameter is not a hash" do
      it "returns true if the action is permitted" do
        role.allowed_to?('bar').should be true
      end

      it "returns false if the aciton is not permitted" do
        role.allowed_to?('notbar').should be false
      end
    end
  end
end
