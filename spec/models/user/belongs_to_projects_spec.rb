require 'spec_helper'

describe User, '#belongs_to_projects' do

  let(:user) { Factory.build(:user) }

  it 'does something' do
    user.belongs_to_projects
  end

end
