require 'spec_helper'

describe Role, '#add_permission!' do

  let(:role) { Role.create({:name => 'role'}) }

  it 'adds each parameter to permissions' do
    role.add_permission!('read', 'write')
    role.reload.permissions.should == [:read, :write]
  end

end
