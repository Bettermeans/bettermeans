require 'spec_helper'

describe Role, '.find_all_givable' do

  it 'returns all roles with the given level' do
    role1 = Factory.create(:role, :level => 52)
    role2 = Factory.create(:role, :level => 52)
    role1.move_to_bottom
    role3 = Factory.create(:role, :level => 75)
    Role.find_all_givable(52).should == [role2, role1]
  end

end
