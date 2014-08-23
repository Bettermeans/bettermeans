require 'spec_helper'

describe Role, '#remove_permission!' do

  let(:role) { Role.create({:name => 'role'}) }

  it 'removes specified permissions' do
    role.add_permission!('read', 'write')
    role.remove_permission!('read')
    role.permissions.should == [:write]
  end

end
