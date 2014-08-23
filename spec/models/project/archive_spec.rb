require 'spec_helper'

describe Project, '#archive' do

  let(:project) { Project.new }

  it 'returns true upon successful archive of Project transactions' do
    Project.should_receive(:transaction).and_return(:true)
    project.archive
  end

end
