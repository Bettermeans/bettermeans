require 'spec_helper'

describe Role, '#name_translation_key' do

  let(:role) { Role.new }

  it 'returns a translation key for the given role' do
    role.name = 'Pizza'
    role.name_translation_key.should == 'role.pizza'
    role.name = 'Core Team'
    role.name_translation_key.should == 'role.core_team'
  end

end
