require 'spec_helper'

describe Project, '#contributor_list' do

  let(:project) { Project.new }

  it 'returns a hash of contributors to the project' do
    contributors = project.contributors.find(:all,
          :conditions => "roles.builtin = #{Role::BUILTIN_CONTRIBUTOR}")
    project.contributor_list
    project.contributor_list.should == contributors
  end

end
