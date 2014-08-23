require 'spec_helper'

describe Project, '#locked?' do

  let(:project) { Project.new }

  context 'if status is STATUS_LOCKED' do
    it 'returns true' do
      project.status = Project::STATUS_LOCKED
      project.locked?.should be true
    end
  end
  context 'if status is not STATUS_LOCKED' do
    it 'returns false' do
      project.status = Project::STATUS_ARCHIVED
      project.locked?.should be false
    end
  end

end
