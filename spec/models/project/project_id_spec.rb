require 'spec_helper'

describe Project, '#project_id' do

  let(:project) { Project.create!(:name => "New Project") }

  context 'when project is not nil' do
    it 'returns Project instance id' do
      project.project_id.should == project.id
    end
  end

end
