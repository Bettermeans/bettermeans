require 'spec_helper'

describe Issue, '#ready_for_open?' do

  let(:issue) do
    Issue.new(:points => 0, :agree_total => 1)
  end

  it 'returns true if points and agree_total >= 1' do
    issue.ready_for_open?.should be true
  end

  it 'returns false if points is nil' do
    issue.points = nil
    issue.ready_for_open?.should be false
  end

  it 'returns false if agree_total < 1' do
    issue.agree_total = 0
    issue.ready_for_open?.should be false
  end

end
