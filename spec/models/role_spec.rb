require 'spec_helper'

describe Role do
  let(:role) { Role.create({
      :name => 'role'
    })
  }
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
      role.builtin = 1
      role.should be_builtin
    end

    it "returns false if builtin is 0" do
      role.builtin = 0
      role.should_not be_builtin
    end
  end

  describe "#community_member?" do
    it "returns true if builtin ~= 3..10 except 6" do
      [3,4,5,7,8,9,10].each do |builtin|
        role.builtin = builtin
        role.should be_community_member
      end
    end

    it "returns false for any builtin other than 3..10" do
      role.builtin = 6
      role.should_not be_community_member
    end
  end

  describe "#enterprise_member?" do
    it "returns true if level is 1" do
      role.level = 1
      role.should be_enterprise_member
    end

    it "returns false if level is not 1" do
      role.level = 2
      role.should_not be_enterprise_member
    end
  end

  describe "#platform_member?" do
    it "returns true if level is 0" do
      role.level = 0
      role.should be_platform_member
    end

    it "returns false if level is not 0" do
      role.level = 1
      role.should_not be_platform_member
    end
  end

  describe "#binding_member?" do
    it "returns true if builtin is in [3,4,8]" do
      [3,4,8].each do |builtin|
        role.builtin = builtin
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
      role.builtin = 3
      role.should be_admin
    end

    it "returns false if builtin is not 3" do
      role.builtin = 1
      role.should_not be_admin
    end
  end

  describe "#core_member?" do
    it "returns true if builtin is 4" do
      role.builtin = 4
      role.should be_core_member
    end

    it "returns false if builtin is not 4" do
      role.builtin = 1
      role.should_not be_core_member
    end
  end

  describe "#contributor?" do
    it "returns true if builtin is 5" do
      role.builtin = 5
      role.should be_contributor
    end

    it "returns false if builtin is not 5" do
      role.builtin = 1
      role.should_not be_contributor
    end
  end

  describe "#member?" do
    it "returns true if builtin is 8" do
      role.builtin = 8
      role.should be_member
    end

    it "returns false if builtin is not 8" do
      role.builtin = 1
      role.should_not be_member
    end
  end
end
