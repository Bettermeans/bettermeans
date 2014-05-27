require 'spec_helper'

describe Role, '.builtin' do

  let!(:builtin_role) { Factory.create(:role, :builtin => 0) }
  let!(:non_builtin_role) { Factory.create(:role, :builtin => 52) }

  it 'returns builtin roles' do
    roles = Role.builtin
    roles.should include(builtin_role)
    roles.should_not include(non_builtin_role)
  end

  context 'when given true' do
    it 'returns non-builtin roles' do
      roles = Role.builtin(true)
      roles.should include(non_builtin_role)
      roles.should_not include(builtin_role)
    end
  end

end
