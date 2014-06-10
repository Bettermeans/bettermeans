require 'spec_helper'

describe Issue, '#ready_for_open?' do

  let(:issue) {
    Issue.new(:agree => 2, :disagree => 0, :points => 0, :agree_total => 1)
  }

  context 'when points are not nil and agree_total exceeds 0' do
    context 'when agree-disagree difference exceeds minimum' do
      it 'returns true' do
        issue.stub(:points_from_credits).and_return 0
        issue.should be_ready_for_open
      end
    end
  end

end
