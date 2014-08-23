require 'spec_helper'

describe Project, '#unlock' do

  let(:project) { Factory.create(:project) }

  before(:each) { project.status = Project::STATUS_LOCKED }

  context 'if status is currently locked' do
    it 'should unlock the project and return true' do
      expect {
        project.unlock
      }.to change{
        project.status
      }.from(Project::STATUS_LOCKED).to(Project::STATUS_ACTIVE)
    end
  end

end
