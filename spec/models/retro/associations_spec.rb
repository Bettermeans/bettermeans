require 'spec_helper'

describe Retro, 'associations' do

  it { should belong_to(:project) }

  it { should have_many(:issues) }
  it { should have_many(:journals).through(:issues) }
  it { should have_many(:issue_votes).through(:issues) }
  it { should have_many(:retro_ratings) }
  it { should have_many(:credit_distributions) }

end
