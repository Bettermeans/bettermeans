require 'spec_helper'

describe Project, '#lock' do

  let(:project) { Factory.create(:project) }

  before(:each) { project.status = Project::STATUS_ACTIVE }

  context 'if status is active and not currently locked' do
    it 'should lock the project and return true' do
      expect {
        project.lock
      }.to change{
        project.status
      }.from(Project::STATUS_ACTIVE).to(Project::STATUS_LOCKED)
    end
  end

end
