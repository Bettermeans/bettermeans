require 'spec_helper'

describe Tracker, 'validations' do

  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:name) }

end
