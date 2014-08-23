require 'spec_helper'

describe Project, '#archived?' do

  let(:project) { Project.new }

  context 'if status is STATUS_ARCHIVED' do
    it 'returns true' do
      project.status = Project::STATUS_ARCHIVED
      project.archived?.should be true
    end
  end
  context 'if status is not STATUS_ARCHIVED' do
    it 'returns false' do
      project.status = Project::STATUS_ACTIVE
      project.archived?.should be false
    end
  end

end
