require 'spec_helper'

describe Project, '#active?' do

  let(:project) { Project.new }

  context 'if status is STATUS_ACTIVE' do
    it 'returns true' do
      project.status = Project::STATUS_ACTIVE
      project.active?.should be true
    end
  end
  context 'if status is not STATUS_ACTIVE' do
    it 'returns false' do
      project.status = Project::STATUS_ARCHIVED
      project.active?.should be false
    end
  end

end
