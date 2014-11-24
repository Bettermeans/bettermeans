require 'spec_helper'

describe Role, '.active' do

  let(:role) { Role.find_by_builtin(Role::BUILTIN_ACTIVE) }
	it 'returns the role with builtin active' do
    Role.active.should == role
	end

  it 'raises an error when there is no role with active builtin' do
    expect {
      role.delete
      Role.active
    }.to raise_error('Missing active builtin role.')
  end
end