require 'spec_helper'

describe Project, '#clearance_members' do

  let(:project) { Project.new }

  it 'returns a hash of project users with clearance' do
    members = project.all_members.find(:all,
          :conditions => "roles.builtin = #{Role::BUILTIN_CLEARANCE}")
    project.clearance_members
    project.clearance_members.should == members
  end

end
