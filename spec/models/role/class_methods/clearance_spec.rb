require 'spec_helper'

describe Role, '.clearance' do

  let(:role) { Role.find_by_builtin(Role::BUILTIN_CLEARANCE) }
	it 'returns the role with builtin clearance' do
    Role.clearance.should == role
	end

  it 'raises an error when there is no role with clearance builtin' do
    expect {
      role.delete
      Role.clearance
    }.to raise_error('Missing clearance builtin role.')
  end
end