require 'spec_helper'

describe Role, '#to_s' do

  let(:role) { Role.create({:name => 'role'}) }

  it 'returns the name' do
    role.name = 'Core Team'
    role.to_s.should == 'Core Team'
  end

end
