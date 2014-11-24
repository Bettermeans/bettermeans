require 'spec_helper'

describe Role, '#before_destroy' do

  let(:role) { Role.board }

  it 'raises an error if the role has members' do
    member = Factory.create(:member, :roles => [role])
    expect {
      role.destroy
    }.to raise_error("Can't delete role")
  end

  it 'raises an error if the role is builtin' do
    expect {
      role.destroy
    }.to raise_error("Can't delete builtin role")
  end

  it 'destroys when there are no members and the role is not builtin' do
    role.update_attributes!(:builtin => 0)
    role.destroy
    Role.find_by_id(role.id).should_not be
  end

end
