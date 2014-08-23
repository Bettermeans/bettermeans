require 'spec_helper'

describe Project, '#enterprise?' do

  let(:project) { Project.new }

  context 'when parent_id is nil' do
    it 'returns true' do
      project.enterprise?.should be true
    end
  end

  context 'when parent_id is not nil' do
    it 'returns false' do
      project1 = Factory.create(:project)
      project2 = Factory.create(:project)
      project2.move_to_child_of(project1)
      project2.enterprise?.should be false
    end
  end

end
