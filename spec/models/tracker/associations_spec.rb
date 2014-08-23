require 'spec_helper'

describe Tracker, 'associations' do

  it { should have_many(:issues) }
  it { should have_many(:workflows) }
  it { should have_many(:projects_trackers) }
  it { should have_many(:projects).through(:projects_trackers) }

end
