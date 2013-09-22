require 'spec_helper'

describe Enterprise do
  let(:enterprise) { Factory.build(:enterprise) }

  it { should have_one(:root_project) }
  it { should have_many(:projects) }
  it { should have_many(:issues).through(:projects) }
  it { should have_many(:members).through(:projects) }
  it { should have_many(:users).through(:members) }
  it { should have_many(:news).through(:projects) }
end
