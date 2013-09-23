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
end
