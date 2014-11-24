require 'spec_helper'

describe Tracker, '#workflow.copy' do

  let(:source_role) { Factory.create(:role) }
  let(:target_role) { Factory.create(:role) }
  let!(:workflow) { Factory.create(:workflow, :role => source_role) }

  it 'copies workflows from the source to the target' do
    target_role.workflows.copy(source_role)
    target_role.workflows.should_not be_empty
  end
end
