require 'spec_helper'

describe Role, '#permissions=' do

  let(:role) { Role.create({:name => 'role'}) }

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
