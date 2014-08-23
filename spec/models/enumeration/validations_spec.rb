require 'spec_helper'

describe Enumeration, 'validations' do

  it { should validate_presence_of(:name) }

end
