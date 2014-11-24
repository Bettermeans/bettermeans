require 'spec_helper'

describe Role, '.board' do

  let(:role) { Role.find_by_builtin(Role::BUILTIN_BOARD) }
	it 'returns the role with builtin board' do
    Role.board.should == role
	end

  it 'raises an error when there is no role with board builtin' do
    expect {
      role.delete
      Role.board
    }.to raise_error('Missing Board builtin role.')
  end
end