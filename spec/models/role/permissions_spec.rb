require 'spec_helper'

describe Role, '#permissions' do

  let(:role) { Role.create({:name => 'role'}) }

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
