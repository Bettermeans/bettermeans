require 'spec_helper'

describe Tracker, '#workflow.copy' do

  let(:source_tracker) { Factory.create(:tracker) }
  let(:target_tracker) { Factory.create(:tracker) }
  let!(:workflow) { Factory.create(:workflow, :tracker => source_tracker) }

  it 'copies workflows from the source to the target' do
    target_tracker.workflows.copy(source_tracker)
    target_tracker.workflows.should_not be_empty
  end
end
