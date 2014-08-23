require 'spec_helper'

describe Project, '#active_members' do

  let(:project) { Project.new }

  it 'returns a hash of active project users' do
    members = project.all_members.find(:all,
          :conditions => "roles.builtin = #{Role::BUILTIN_ACTIVE}")
    project.all_members
    project.active_members.should == members
  end

end
